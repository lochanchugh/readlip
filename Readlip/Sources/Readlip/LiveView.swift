//
//  ContentView.swift
//  lipread
//
//  Created by Lochan on 24/02/25.


import SwiftUI
import AVFoundation
import Speech
import Vision


class CameraManager: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    @Published var recognizedText = ""
    @Published var isAnalyzing = false
    
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var lipHighlightLayer: CAShapeLayer?
    private var videoDataOutput: AVCaptureVideoDataOutput?
    private let videoDataOutputQueue = DispatchQueue(label: "LipReadingQueue", qos: .userInitiated)
    
    private let speechAnalyzer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var textAnalysisRequest: SFSpeechAudioBufferRecognitionRequest?
    private var textAnalysisTask: SFSpeechRecognitionTask?
    private let audioProcessor = AVAudioEngine()
    
    func initializeLipReadingSystem() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            if granted {
                SFSpeechRecognizer.requestAuthorization { authStatus in
                    DispatchQueue.main.async {
                        if authStatus == .authorized {
                            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                                DispatchQueue.main.async {
                                    if granted {
                                        self?.initializeTextAnalysis()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func initializeTextAnalysis() {
        if audioProcessor.isRunning {
            audioProcessor.stop()
            textAnalysisRequest?.endAudio()
            isAnalyzing = false
            return
        }
        
        textAnalysisTask?.cancel()
        textAnalysisTask = nil
        
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try? audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        textAnalysisRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioProcessor.inputNode
        guard let textAnalysisRequest = textAnalysisRequest else { return }
        
        textAnalysisRequest.shouldReportPartialResults = true
        
        textAnalysisTask = speechAnalyzer?.recognitionTask(with: textAnalysisRequest) { [weak self] result, _ in
            if let result = result {
                DispatchQueue.main.async {
                    self?.recognizedText = result.bestTranscription.formattedString
                }
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            textAnalysisRequest.append(buffer)
        }
        
        audioProcessor.prepare()
        try? audioProcessor.start()
        isAnalyzing = true
    }
    
    func startLipReadingSession(in view: UIView) {
        let screenWidth = UIScreen.main.bounds.width
        let topPadding: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 40 : 60
        let squareSize = screenWidth - 40
        
        let facialAnalysisContainer = UIView(frame: CGRect(x: 0, y: 0, width: squareSize, height: squareSize))
        facialAnalysisContainer.backgroundColor = .black
        
        let session = AVCaptureSession()
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: device) else {
            return
        }
        
        session.addInput(input)
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
            self.videoDataOutput = videoOutput
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = facialAnalysisContainer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        facialAnalysisContainer.layer.addSublayer(previewLayer)
        
        lipHighlightLayer = CAShapeLayer()
        lipHighlightLayer?.fillColor = UIColor.clear.cgColor
        lipHighlightLayer?.strokeColor = UIColor.green.cgColor
        lipHighlightLayer?.lineWidth = 2.0
        facialAnalysisContainer.layer.addSublayer(lipHighlightLayer!)
        
        view.addSubview(facialAnalysisContainer)
        
        facialAnalysisContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            facialAnalysisContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: topPadding),
            facialAnalysisContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            facialAnalysisContainer.widthAnchor.constraint(equalToConstant: squareSize),
            facialAnalysisContainer.heightAnchor.constraint(equalToConstant: squareSize)
        ])
        
        session.startRunning()
        
        self.captureSession = session
        self.previewLayer = previewLayer
        
        initializeLipReadingSystem()
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let facialAnalysisRequest = VNDetectFaceLandmarksRequest { [weak self] request, _ in
            guard let self = self,
                  let observations = request.results as? [VNFaceObservation] else { return }
            self.analyzeLipConfiguration(from: observations)
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: imageBuffer, orientation: .right, options: [:])
        try? handler.perform([facialAnalysisRequest])
    }
    
    private func analyzeLipConfiguration(from observations: [VNFaceObservation]) {
        guard let face = observations.first,
              let landmarks = face.landmarks,
              let outerLips = landmarks.outerLips?.normalizedPoints,
              let innerLips = landmarks.innerLips?.normalizedPoints else {
            return
        }
        
        updateLipHighlight(outerLips: outerLips, innerLips: innerLips)
    }
    
    private func updateLipHighlight(outerLips: [CGPoint], innerLips: [CGPoint]) {
        DispatchQueue.main.async {
            guard let previewLayer = self.previewLayer else { return }
            
            let path = UIBezierPath()
            
            let outerLipPoints = outerLips.map {
                previewLayer.layerPointConverted(fromCaptureDevicePoint: CGPoint(
                    x: $0.x,
                    y: 1 - $0.y
                ))
            }
            
            let innerLipPoints = innerLips.map {
                previewLayer.layerPointConverted(fromCaptureDevicePoint: CGPoint(
                    x: $0.x,
                    y: 1 - $0.y
                ))
            }
            
            if let first = outerLipPoints.first {
                path.move(to: first)
                outerLipPoints.dropFirst().forEach { path.addLine(to: $0) }
                path.close()
            }
            if let first = innerLipPoints.first {
                path.move(to: first)
                innerLipPoints.dropFirst().forEach { path.addLine(to: $0) }
                path.close()
            }
            
            self.lipHighlightLayer?.path = path.cgPath
        }
    }
    
    func deactivateTextAnalysis() {
        audioProcessor.stop()
        textAnalysisRequest?.endAudio()
        isAnalyzing = false
    }
    
    func endLipReadingSession() {
        captureSession?.stopRunning()
        previewLayer?.removeFromSuperlayer()
        deactivateTextAnalysis()
    }
}

struct LiveView: View {
    @StateObject private var lipReadingManager = CameraManager()
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                Color.clear
                    .frame(width: UIScreen.main.bounds.width - 40,
                           height: UIScreen.main.bounds.width - 40)
                
                VStack(spacing: 15) {
                    ScrollView {
                        Text(lipReadingManager.recognizedText)
                            .font(.body)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                            .multilineTextAlignment(.center)
                    }
                    
                    Text(lipReadingManager.isAnalyzing ? "..." : "....")
                        .foregroundColor(lipReadingManager.isAnalyzing ? .green : .yellow)
                        .font(.caption)
                }
                .padding()
                
                Spacer()
            }
            .padding(.top, UIDevice.current.userInterfaceIdiom == .pad ? 60 : 40)
        }
        .onAppear {
            if let window = UIApplication.shared.windows.first {
                lipReadingManager.startLipReadingSession(in: window.rootViewController!.view)
            }
        }
    }
}
