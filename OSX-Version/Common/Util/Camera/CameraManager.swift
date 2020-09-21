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

protocol CameraManagerDelegate: class {
    func imagenCapturada(image: NSImage)
}

class CameraManager: NSObject {
    weak var delegate : CameraManagerDelegate?
    
    var session : AVCaptureSession = AVCaptureSession()
    
    var tamañoActual : Int!
    var tamañoOriginal : Int!
    
    var imagen = NSImage() {
        didSet {
            self.delegate?.imagenCapturada(image: self.imagen)
            
        }
    }
    
    override init() {
        super .init()
        correrSessionCamara()
    }
    
    var output : AVCaptureStillImageOutput!
    

    func tomarFotoPressed(completion: @escaping (NSImage?) -> ()) {
        guard let connection = output.connection(with: AVMediaType.video) else { return }
        connection.videoOrientation = .portrait
        
        output.captureStillImageAsynchronously(from: connection) { (sampleBuffer, error) in
            guard sampleBuffer != nil && error == nil else { return }
            
            let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer!)
            guard let image = NSImage(data: imageData!) else
            {
                completion(nil)
                return
                
            }
            
            completion(image)
        }
    }
    
    func StopSession() {
        session.stopRunning()
    }
    
    func correrSessionCamara() {
        session.sessionPreset = AVCaptureSession.Preset.photo
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front) else {
            fatalError("no front camera. but don't all iOS 10 devices have them?")
            return
        }
            
            
        
        if let device : [AVCaptureDevice] = AVCaptureDevice.devices() {
            print("device found = ",device.count)
            print(device)
   
            let device_input : AVCaptureDeviceInput = try! AVCaptureDeviceInput(device: device[0])
            
            let previewLayer:AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
            
            output = AVCaptureStillImageOutput()
            
            output.outputSettings = [ AVVideoCodecKey: AVVideoCodecType.jpeg ]
            
            guard session.canAddInput(device_input) && session.canAddOutput(output) else { return }
            
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


