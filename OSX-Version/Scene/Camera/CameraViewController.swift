//
//  MLCamaraViewController.swift
//  Body Life 2
//
//  Created by David Diego Gomez on 10/7/19.
//  Copyright © 2019 Gomez David Diego. All rights reserved.
//

import Cocoa
import AVFoundation
import AVKit

protocol CameraViewControllerDelegate: class {
    func imagenCapturada(image: NSImage)
}

class CameraViewController: NSViewController {
    
    weak var delegate : CameraViewControllerDelegate?
    
    @IBOutlet var previewCam: AVCaptureView!
    
    @IBOutlet weak var imagenTomada: NSImageView!
    
    var session : AVCaptureSession = AVCaptureSession()
    
    var tamañoActual : Int!
    var tamañoOriginal : Int!
    
    var imagen = NSImage() {
        didSet {
            DispatchQueue.main.async {
                self.imagenTomada.image = self.imagen
                self.session.stopRunning()
                self.view.window?.close()
                self.delegate?.imagenCapturada(image: self.imagen)
                
            }
        }
    }
    var output : AVCaptureStillImageOutput!
    
    
    override func viewDidLoad() {
        
        correrSessionCamara()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        // preferredContentSize = NSSize(width: 500, height: 600)
        preferredContentSize = view.fittingSize
    }
    
    @IBAction func tomarFotoPressed(_ sender: Any) {
        guard let connection = output.connection(with: AVMediaType.video) else { return }
        connection.videoOrientation = .portrait
        
        output.captureStillImageAsynchronously(from: connection) { (sampleBuffer, error) in
            guard sampleBuffer != nil && error == nil else { return }
            
            let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer!)
            guard let image = NSImage(data: imageData!) else { return }
            self.imagen = image
        }
    }
    
    @IBAction func cancelarClicked(_ sender: Any) {
        session.stopRunning()
        view.window?.close()
    }
    
    func correrSessionCamara() {
        view.wantsLayer = true
        previewCam.wantsLayer = true
        
        session.sessionPreset = AVCaptureSession.Preset.photo
        
        if let device : [AVCaptureDevice] = AVCaptureDevice.devices() {
            print("device found = ",device.count)
            print(device)
            
            let device_input : AVCaptureDeviceInput = try! AVCaptureDeviceInput(device: device[0])
            
            
            let previewLayer:AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
            
            output = AVCaptureStillImageOutput()
            
            output.outputSettings = [ AVVideoCodecKey: AVVideoCodecType.jpeg ]
            
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
            
        }
        session.startRunning()
        
    }
}

