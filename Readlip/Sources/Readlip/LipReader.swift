//
//  LipReader.swift
//  lipread
//
//  Created by Lochan on 24/02/25.
//


import SwiftUI
import AVFoundation
import Vision

class LipReader: NSObject, ObservableObject {
    private var captureSession: AVCaptureSession!
    private var videoCaptureDevice: AVCaptureDevice!
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    @Published var lipPosition = "No lips detected"
    
    override init() {
        super.init()
        setupCamera()
    }

    private func setupCamera() {
        captureSession = AVCaptureSession()
        
        // Set up the capture device (front camera)
        videoCaptureDevice = AVCaptureDevice.default(for: .video)
        let videoDeviceInput = try? AVCaptureDeviceInput(device: videoCaptureDevice)
        
        if captureSession.canAddInput(videoDeviceInput!) {
            captureSession.addInput(videoDeviceInput!)
        }
        
        // Set up the camera output
        let videoDataOutput = AVCaptureVideoDataOutput()
        if captureSession.canAddOutput(videoDataOutput) {
            captureSession.addOutput(videoDataOutput)
        }
        
        videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.frame = UIScreen.main.bounds
        videoPreviewLayer.videoGravity = .resizeAspectFill
    }
    
    func startReading() {
        captureSession.startRunning()
    }

    func stopReading() {
        captureSession.stopRunning()
    }
}

extension LipReader: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let request = VNDetectFaceLandmarksRequest(completionHandler: { request, error in
            guard let results = request.results as? [VNFaceObservation], let face = results.first else {
                DispatchQueue.main.async {
                    self.lipPosition = "No lips detected"
                }
                return
            }
            
            if let landmarks = face.landmarks, let lips = landmarks.leftEye {
                DispatchQueue.main.async {
                    self.lipPosition = "Lip positions: \(lips)"
                }
            }
        })
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        try? handler.perform([request])
    }
}
