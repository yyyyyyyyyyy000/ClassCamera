//
//  CameraController.swift
//  ClassCamera
//
//  Created by 无敌帅的yyyyy on 2019/4/3.
//  Copyright © 2019年 无敌帅的yyyy. All rights reserved.
//

import AVFoundation
import UIKit


class CameraController:NSObject, AVCapturePhotoCaptureDelegate {
    var captureSession: AVCaptureSession?
    var photoOutput: AVCapturePhotoOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var rearCamera: AVCaptureDevice?
    var rearCameraInput: AVCaptureDeviceInput?
    //let queue = DispatchQueue(label: "a", qos: .userInteractive, attributes: .init(rawValue: 0), autoreleaseFrequency: .never, target: nil)
    
    var photoCaptureCompletionBlock:((UIImage?)->Void)?
    
    
    
}

extension CameraController {
    
    func displayPreview(on view: UIView) throws {
        guard let captureSession = self.captureSession, captureSession.isRunning else { fatalError("CameraControllerError.captureSessionIsMissing") }
        
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.previewLayer?.connection?.videoOrientation = .portrait
        
        view.layer.insertSublayer(self.previewLayer!, at: 0)
        self.previewLayer?.frame = view.frame
    }
    
    
    func captureImage(completion:@escaping (UIImage?)->Void){
        guard let captureSession = captureSession,captureSession.isRunning else{
            fatalError()
        }
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .off
        
        self.photoOutput?.capturePhoto(with: settings, delegate: self)
        self.photoCaptureCompletionBlock = completion
    }
    
    
    
    func prepare(completionHandler: @escaping (Error?) -> Void) {
        func createCaptureSession() {
            self.captureSession = AVCaptureSession()
        }
        
        func configureCaptureDevices() throws {
            guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
                fatalError("No video device found")
            }
            rearCamera = captureDevice
        }
        
        func configureDeviceInputs() throws {
            guard let captureSession = self.captureSession else { fatalError("CameraControllerError.captureSessionIsMissing") }
            
            if let rearCamera = self.rearCamera {
                self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
                
                if captureSession.canAddInput(self.rearCameraInput!) { captureSession.addInput(self.rearCameraInput!) }
            }else { print("CameraControllerError.noCamerasAvailable") }
        }
        
        func configurePhotoOutput() throws {
            guard let captureSession = self.captureSession else { fatalError("CameraControllerError.captureSessionIsMissing") }
            
            self.photoOutput = AVCapturePhotoOutput()
            self.photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
            if captureSession.canAddOutput(self.photoOutput!) { captureSession.addOutput(self.photoOutput!) }
            captureSession.startRunning()
        }
        
        DispatchQueue(label: "prepare").async {
            do {
                createCaptureSession()
                try configureCaptureDevices()
                try configureDeviceInputs()
                try configurePhotoOutput()
            }
            catch {
                DispatchQueue.main.async {
                    completionHandler(error)
                }
                return
            }
            DispatchQueue.main.async {
                completionHandler(nil)
            }
        }
    }
    
    
}
extension CameraController{
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        if let buffer = photoSampleBuffer, let data = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: buffer, previewPhotoSampleBuffer: nil), let image = UIImage(data: data){
            self.photoCaptureCompletionBlock?(image)
        }else{
            self.photoCaptureCompletionBlock?(nil)
        }
            
        
        
        
        
    }
}
