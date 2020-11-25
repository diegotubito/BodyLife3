//
//  CameraManager.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 17/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa
import AVFoundation
import AVKit

protocol CameraViewControllerDelegate: class {
    func capturedImage(originalSize image: NSImage)
}

class CameraViewController: NSViewController {
    weak var delegate : CameraViewControllerDelegate?
    @IBOutlet var previewCam: AVCaptureView!
    var session : AVCaptureSession = AVCaptureSession()
    var output = AVCapturePhotoOutput()
    
    var capturedImage = NSImage() {
        didSet {
            DispatchQueue.main.async {
                self.session.stopRunning()
                self.view.window?.close()
                self.delegate?.capturedImage(originalSize: self.capturedImage)
            }
        }
    }
    
    override func viewDidLoad() {
        super .viewDidLoad()
        setupSession()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        preferredContentSize = view.fittingSize
    }
    
    @IBAction func tomarFotoPressed(_ sender: Any) {
        guard let connection = output.connection(with: AVMediaType.video) else { return }
        connection.videoOrientation = .portrait
        let photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey:AVVideoCodecType.jpeg])
        output.capturePhoto(with: photoSettings, delegate: self)
    }
    
    @IBAction func cancelarClicked(_ sender: Any) {
        session.stopRunning()
        view.window?.close()
    }
    
    func setupSession() {
        view.wantsLayer = true
        previewCam.wantsLayer = true
        session.sessionPreset = AVCaptureSession.Preset.photo
        guard let device = bestDevice(in: .unspecified) else {
            return
        }
        
        let device_input : AVCaptureDeviceInput = try! AVCaptureDeviceInput(device: device)
        let previewLayer:AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        guard session.canAddInput(device_input) && session.canAddOutput(output) else { return }
        previewLayer.frame = previewCam.bounds
        previewLayer.videoGravity = AVLayerVideoGravity.resize
        self.previewCam.layer?.addSublayer(previewLayer)
        if session.canAddInput(device_input)
        {
            session.addInput(device_input)
        }
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        session.startRunning()
    }
    
    func bestDevice(in position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let discoverySession = AVCaptureDevice.DiscoverySession.init(deviceTypes: [.builtInWideAngleCamera, .externalUnknown], mediaType: nil, position: .unspecified)
        
      
        let devices = discoverySession.devices
        guard !devices.isEmpty else {
            print("There's no camera device.")
            return nil
        }
        
        return devices.first(where: { device in device.position == position })!
    }
}

extension CameraViewController : AVCapturePhotoCaptureDelegate{
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        let imageData = photo.fileDataRepresentation()
        if let data = imageData, let img = NSImage(data: data) {
            self.capturedImage = img
        }
    }
}
