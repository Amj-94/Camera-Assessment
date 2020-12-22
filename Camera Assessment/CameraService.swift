//
//  CameraService.swift
//  Camera Assessment
//
//  Created by Abo-Aljoud94 on 12/21/20.
//

import UIKit
import AVKit
import Vision

protocol CameraServiceDelegate {
    func didStartFraming(faceObservations: [VNFaceObservation])
//    func didStartFraming(faceObservations: [CGPoint])
//    func didStartFraming(topLeft: CGPoint, topright: CGPoint, bottomLeft: CGPoint, bottomRight: CGPoint)
}

class CameraService: NSObject {
    // MARK: -Properties
    private weak var previewView: UIView?
    private(set) var cameraIsReadyToUse = false
    private let session = AVCaptureSession()
     weak var previewLayer: AVCaptureVideoPreviewLayer?
    private lazy var capturePhotoOutput = AVCapturePhotoOutput()
    
    private var snapshotImageOrientation = UIImage.Orientation.upMirrored
    private var cameraPosition = AVCaptureDevice.Position.front {
        didSet {
            switch cameraPosition {
                case .front: snapshotImageOrientation = .upMirrored
                case .unspecified, .back: fallthrough
                @unknown default: snapshotImageOrientation = .up
            }
        }
    }
    
    private var captureCompletionBlock: ((UIImage) -> Void)?
    private var preparingCompletionHandler: ((Bool) -> Void)?
    
    private var detectionRequests: [VNDetectFaceRectanglesRequest]?
    private var trackingRequests: [VNTrackObjectRequest]?
    
    lazy var sequenceRequestHandler = VNSequenceRequestHandler()
    
    var startFraming: Bool?
    
    var delegate: CameraServiceDelegate!
    
    // MARK: -Funcs
    
    func prepare(previewView: UIView,
                 cameraPosition: AVCaptureDevice.Position,
                 completion: ((Bool) -> Void)?) {
        self.previewView = previewView
        self.preparingCompletionHandler = completion
        self.cameraPosition = cameraPosition
        checkCameraAccess { allowed in
            if allowed { self.setup() }
            completion?(allowed)
            self.preparingCompletionHandler = nil
        }
    }
    
    private func setup() {
        configureCaptureSession()
    }
    func start() {
        if cameraIsReadyToUse {
            session.startRunning()
        }
    }
    func stop() {
        session.stopRunning()
    }
    
    private func askUserForCameraPermission(_ completion:  ((Bool) -> Void)?) {
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { (allowedAccess) -> Void in
            DispatchQueue.main.async { completion?(allowedAccess) }
        }
    }
    
    private func checkCameraAccess(completion: ((Bool) -> Void)?) {
        askUserForCameraPermission { [weak self] allowed in
            guard let self = self, let completion = completion else { return }
            self.cameraIsReadyToUse = allowed
            if allowed {
                completion(true)
            } else {
                self.showDisabledCameraAlert(completion: completion)
            }
        }
    }
    
    private func configureCaptureSession() {
        guard let previewView = previewView else { return }
        // Define the capture device we want to use

        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: cameraPosition) else {
            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "No front camera available"])
            show(error: error)
            return
        }

        // Connect the camera to the capture session input
        do {

            try camera.lockForConfiguration()
            defer { camera.unlockForConfiguration() }

            if camera.isFocusModeSupported(.continuousAutoFocus) {
                camera.focusMode = .continuousAutoFocus
            }

            if camera.isExposureModeSupported(.continuousAutoExposure) {
                camera.exposureMode = .continuousAutoExposure
            }

            let cameraInput = try AVCaptureDeviceInput(device: camera)
            session.addInput(cameraInput)

        } catch {
            show(error: error as NSError)
            return
        }

        // Create the video data output
        let videoOutput = AVCaptureVideoDataOutput()
        let dataOutputQueue = DispatchQueue(label: "Face Detection Test")
        videoOutput.setSampleBufferDelegate(self, queue: dataOutputQueue)
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]

        // Add the video output to the capture session
        session.addOutput(videoOutput)

        let videoConnection = videoOutput.connection(with: .video)
        videoConnection?.videoOrientation = .portrait

        // Configure the preview layer
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = previewView.bounds
        previewView.layer.insertSublayer(previewLayer, at: 0)
        self.previewLayer = previewLayer
    }
    
    private func show(alert: UIAlertController) {
        DispatchQueue.main.async {
            UIApplication.topViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    private func show(error: NSError) {
        let alertVC = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil ))
        show(alert: alertVC)
    }
    
    private func showDisabledCameraAlert(completion: ((Bool) -> Void)?) {
        let alertVC = UIAlertController(title: "Enable Camera Access",
                                        message: "Please provide access to your camera",
                                        preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Go to Settings", style: .default, handler: { action in
            guard   let previewView = self.previewView,
                    let settingsUrl = URL(string: UIApplication.openSettingsURLString),
                    UIApplication.shared.canOpenURL(settingsUrl) else { return }
            UIApplication.shared.open(settingsUrl) { [weak self] _ in
                guard let self = self else { return }
                self.prepare(previewView: previewView,
                              cameraPosition: self.cameraPosition,
                              completion: self.preparingCompletionHandler)
            }
        }))
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in completion?(false) }))
        show(alert: alertVC)
    }
    
    func prepareVisionRequest() {
        var requests = [VNTrackObjectRequest]()
        
        let faceDetectionRequest = VNDetectFaceRectanglesRequest(completionHandler: { (request, error) in
            
            if error != nil {
                print("FaceDetection error: \(String(describing: error)).")
            }
            
            guard let faceDetectionRequest = request as? VNDetectFaceRectanglesRequest,
                let results = faceDetectionRequest.results as? [VNFaceObservation] else {
                    return
            }
            DispatchQueue.main.async {
                // Add the observations to the tracking list
                for observation in results {
                    let faceTrackingRequest = VNTrackObjectRequest(detectedObjectObservation: observation)
                    requests.append(faceTrackingRequest)
                }
                self.trackingRequests = requests
            }
        })
        
        // Start with detection.  Find face, then track it.
        detectionRequests = [faceDetectionRequest]
        
        sequenceRequestHandler = VNSequenceRequestHandler()
    
    }
    
    func exifOrientationForCurrentDeviceOrientation() -> CGImagePropertyOrientation {
        return exifOrientationForDeviceOrientation(UIDevice.current.orientation)
    }
    
    func exifOrientationForDeviceOrientation(_ deviceOrientation: UIDeviceOrientation) -> CGImagePropertyOrientation {
        
        switch deviceOrientation {
        case .portraitUpsideDown:
            return .rightMirrored
            
        case .landscapeLeft:
            return .downMirrored
            
        case .landscapeRight:
            return .upMirrored
            
        default:
            return .leftMirrored
        }
    }
    
    func convertToCGPoint(rect: CGRect) -> [String:CGPoint] {
        print("minx of rect is \(rect.minX), maxX is \(rect.maxX)")
        
        let transform = CGAffineTransform.identity
                .scaledBy(x: 1, y: -1)
            .translatedBy(x: 0, y: -rect.size.height)
            .scaledBy(x: rect.size.width, y: rect.size.height)

        let topLeft = CGPoint(x: rect.minX, y: rect.minY)
        let topRight = CGPoint(x: rect.maxX, y: rect.minY)
        let bottomLeft = CGPoint(x: rect.minX, y: rect.maxY)
        let bottomRight = CGPoint(x: rect.maxX, y: rect.maxY)
        let convertedTopLeft = topLeft.applying(transform)
        let convertedTopRight = topRight.applying(transform)
        let convertedBottomLeft = bottomLeft.applying(transform)
        let convertedBottomRight = bottomRight.applying(transform)
        
        var result = [String:CGPoint]()
        result["topLeft"] = convertedTopLeft
        
        result["topRight"] = convertedTopRight
        
        result["bottomLeft"] = convertedBottomLeft
        
        result["bottomRight"] = convertedBottomRight
        return result
    }
    
    func convertPoint(point: CGPoint) -> CGPoint {
        return previewLayer!.layerPointConverted(fromCaptureDevicePoint: point)
    }
}

    // MARK: -Extensions
extension CameraService: AVCapturePhotoCaptureDelegate {
    func capturePhoto(completion: ((UIImage) -> Void)?) { captureCompletionBlock = completion }
}

extension CameraService: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if captureCompletionBlock != nil {
            if let outputImage = UIImage(sampleBuffer: sampleBuffer, orientation: snapshotImageOrientation) {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    if let captureCompletionBlock = self.captureCompletionBlock{
                        captureCompletionBlock(outputImage)
                        AudioServicesPlayAlertSound(SystemSoundID(1108))
                    }
                    self.captureCompletionBlock = nil
                }
            }
        }
        
        if startFraming != nil && startFraming == true{
            
            var requestHandlerOptions: [VNImageOption: AnyObject] = [:]
            
            let cameraIntrinsicData = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil)
            
            if cameraIntrinsicData != nil {
                requestHandlerOptions[VNImageOption.cameraIntrinsics] = cameraIntrinsicData
            }
            
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                print("Failed to obtain a CVPixelBuffer for the current output frame.")
                return
            }
            
            let exifOrientation = self.exifOrientationForCurrentDeviceOrientation()
            
            guard let requests = self.trackingRequests, !requests.isEmpty else {
                // No tracking object detected, so perform initial detection
                let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
                                                                orientation: exifOrientation,
                                                                options: requestHandlerOptions)
                
                do {
                    guard let detectRequests = self.detectionRequests else {
                        return
                    }
                    try imageRequestHandler.perform(detectRequests)
                } catch let error as NSError {
                    NSLog("Failed to perform FaceRectangleRequest: %@", error)
                }
                return
            }
            
            do {
                try self.sequenceRequestHandler.perform(requests,
                                                         on: pixelBuffer,
                                                         orientation: exifOrientation)
            } catch let error as NSError {
                NSLog("Failed to perform SequenceRequest: %@", error)
            }
            
            // Setup the next round of tracking.
            var newTrackingRequests = [VNTrackObjectRequest]()
            for trackingRequest in requests {
                
                guard let results = trackingRequest.results else {
                    return
                }
                
                guard let observation = results[0] as? VNDetectedObjectObservation else {
                    return
                }
                
                if !trackingRequest.isLastFrame {
                    if observation.confidence > 0.3 {
                        trackingRequest.inputObservation = observation
                    } else {
                        trackingRequest.isLastFrame = true
                    }
                    newTrackingRequests.append(trackingRequest)
                }
            }
            self.trackingRequests = newTrackingRequests
            
            if newTrackingRequests.isEmpty {
                // Nothing to track, so abort.
                return
            }
            
            var faceLandmarkRequests = [VNDetectFaceLandmarksRequest]()
            
            // Perform landmark detection on tracked faces.
            for trackingRequest in newTrackingRequests {
                
                let faceLandmarksRequest = VNDetectFaceLandmarksRequest(completionHandler: { (request, error) in
                    
                    if error != nil {
                        print("FaceLandmarks error: \(String(describing: error)).")
                    }
                    
                    guard let landmarksRequest = request as? VNDetectFaceLandmarksRequest,
                        let results = landmarksRequest.results as? [VNFaceObservation] else {
                            return
                    }
                    
//                    for result in results {
//                        let bounding = result.boundingBox
//                        let convertedTopLeft: CGPoint = self.previewLayer!.layerPointConverted(fromCaptureDevicePoint: CGPoint(x: bounding.minX, y: 1 - bounding.minY))
//                        let convertedTopRight: CGPoint =
//                            self.previewLayer!.layerPointConverted(fromCaptureDevicePoint: CGPoint(x: bounding.maxX, y: 1 - bounding.minY))
//                        let convertedBottomLeft: CGPoint =
//                            self.previewLayer!.layerPointConverted(fromCaptureDevicePoint: CGPoint(x: bounding.minX, y: 1 - bounding.maxY))
//                        let convertedBottomRight: CGPoint =
//                            self.previewLayer!.layerPointConverted(fromCaptureDevicePoint: CGPoint(x: bounding.maxX, y: 1 - bounding.maxY))
////                        let points:[CGPoint] = [convertedTopLeft, convertedTopRight, convertedBottomLeft, convertedBottomRight]
//                        self.delegate.didStartFraming(topLeft: convertedTopLeft, topright: convertedTopRight, bottomLeft: convertedBottomLeft, bottomRight: convertedBottomRight)
////                        self.delegate.didStartFraming(faceObservations: points)
//                    }
                    
                    self.delegate.didStartFraming(faceObservations: results)
                    
    //                 Perform all UI updates (drawing) on the main queue, not the background queue on which this handler is being called.
//                    DispatchQueue.main.async {
//                    }
                })
                guard let trackingResults = trackingRequest.results else {
                    return
                }
                
                guard let observation = trackingResults[0] as? VNDetectedObjectObservation else {
                    return
                }
                let faceObservation = VNFaceObservation(boundingBox: observation.boundingBox)
                faceLandmarksRequest.inputFaceObservations = [faceObservation]
                
                // Continue to track detected facial landmarks.
                faceLandmarkRequests.append(faceLandmarksRequest)
                
                let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
                                                                orientation: exifOrientation,
                                                                options: requestHandlerOptions)
                
                do {
                    try imageRequestHandler.perform(faceLandmarkRequests)
                } catch let error as NSError {
                    NSLog("Failed to perform FaceLandmarkRequest: %@", error)
                }
            }
        }
    }
}
