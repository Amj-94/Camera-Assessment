//
//  CameraVC.swift
//  Camera Assessment
//
//  Created by Abo-Aljoud94 on 12/17/20.
//

import UIKit
import AVKit
import Vision

class CameraVC: UIViewController, AVCapturePhotoCaptureDelegate {
    
    // MARK: -Properties
    private lazy var cameraService = CameraService()
    var testType: String?
    var leftEyeBrow: [CGPoint]?
    var rightEyeBrow: [CGPoint]?
    var noseCrest: [CGPoint]?
    
    var min: CGFloat?
    var mid: CGFloat?
    var max: CGFloat?
    var faceCropFrame = CGRect.zero
    
    
    // MARK: -Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCameraPreviewView()
        setUpLayOut()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraService.start()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cameraService.stop()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    // MARK: -Funcs
    
    func setupCameraPreviewView(){
        let previewView = UIView(frame: .zero)
        view.addSubview(previewView)
        previewView.translatesAutoresizingMaskIntoConstraints = false
        previewView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        previewView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        previewView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        previewView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        cameraService.prepare(previewView: previewView, cameraPosition: .front) { [weak self] success in
            if success {
                self?.cameraService.start()
                self?.cameraService.prepareVisionRequest()
            }
        }
    }
   
    func addBodyActionView(){
        self.cameraService.delegate = self
        let bodyActions = ["Turn your face to the right", "Turn your face to the left"]
        let random = Int.random(in: 0...bodyActions.count - 1)
        let dialog = UIAlertController(title:"Prove you are not a robot", message: bodyActions[random], preferredStyle: .alert)
        let okAction = UIAlertAction(title:"OK", style: .default, handler: {(alert:UIAlertAction!)-> Void in
            self.viFaceCorp.frame = CGRect(x: self.view.frame.width * 0.15, y: self.view.frame.height * 0.25, width: self.view.frame.width * 0.7, height: self.view.frame.height * 0.5)
            self.view.addSubview(self.viFaceCorp)
            self.testType = bodyActions[random]
            self.cameraService.startFraming = true
            self.faceCropFrame = self.viFaceCorp.frame
            print(self.viFaceCorp.frame)
            print(self.viFaceCorp.layer.frame)
//            self.takePhoto()
        })
        dialog.addAction(okAction)
        self.present(dialog, animated:true, completion:nil)
    }
    
    func addCalculationTest(){
        let vc = CalculationTestView()
        vc.isModalInPresentation = true
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    func addColorTest(){
        let vc = ColorTestVC()
        vc.isModalInPresentation = true
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    func takePhoto(){
        cameraService.capturePhoto { [weak self] image in
            guard let self = self else {return }
            self.testType = nil
            self.min = nil
            self.mid = nil
            self.max = nil
            let vc = ImageViewVC()
            vc.image = image
            self.present(vc, animated: true, completion: nil)
//            self.show(image: image)
        }
//        sleep(2)
//        let shutterView = UIView(frame: previewLayer?.frame ?? .zero)
//        shutterView.backgroundColor = UIColor.black
//        view.addSubview(shutterView)
//        UIView.animate(withDuration: 0.3, animations: {
//            shutterView.alpha = 0
//        }, completion: { (_) in
//            shutterView.removeFromSuperview()
//            let settings = AVCapturePhotoSettings()
//            self.photoOutPut.capturePhoto(with: settings, delegate: self)
//        })
    }
    // MARK: -Selectors
    
    @objc func handleCloseButton(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleCapturePhoto(sender: UIButton) {
//        addColorTest()
//        addCalculationTest()
        addBodyActionView()
//        let random = Int.random(in: 1...3)
//        switch random {
//        case 1:
//            addBodyActionView()
//        case 2:
//            addColorTest()
//        case 3:
//            addCalculationTest()
//
//        default: break
//
//        }
    }
    
    // MARK: -SetUpLayOut
    
    func setUpLayOut(){
        
        view.addSubview(btClose)
        NSLayoutConstraint.activate([btClose.topAnchor.constraint(equalTo: view.topAnchor, constant: 20), btClose.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10), btClose.heightAnchor.constraint(equalToConstant: 60), btClose.widthAnchor.constraint(equalToConstant: 60)])
        btClose.addTarget(self, action: #selector(handleCloseButton(sender:)), for: .touchUpInside)
        
        view.addSubview(viACtions)
        NSLayoutConstraint.activate([viACtions.bottomAnchor.constraint(equalTo: view.bottomAnchor), viACtions.leadingAnchor.constraint(equalTo: view.leadingAnchor), viACtions.trailingAnchor.constraint(equalTo: view.trailingAnchor), viACtions.heightAnchor.constraint(equalToConstant: 60)])
        
        viACtions.addSubview(btCapture)
        NSLayoutConstraint.activate([btCapture.centerXAnchor.constraint(equalTo: view.centerXAnchor), btCapture.centerYAnchor.constraint(equalTo: viACtions.centerYAnchor), btCapture.widthAnchor.constraint(equalToConstant: 50), btCapture.heightAnchor.constraint(equalToConstant: 50)])
        btCapture.layer.cornerRadius = 25
        btCapture.addTarget(self, action: #selector(handleCapturePhoto(sender:)), for: .touchUpInside)
        
    }
    
    // MARK: Controls
    
    let viACtions: UIView = {
        let vi = UIView()
        vi.backgroundColor = .gray
        vi.translatesAutoresizingMaskIntoConstraints = false
        return vi
    }()
    
    let btCapture: UIButton = {
        let bt = UIButton()
        bt.backgroundColor = .white
        bt.layer.masksToBounds = true
        bt.translatesAutoresizingMaskIntoConstraints = false
        return bt
    }()
    
    let btClose: UIButton = {
        let bt = UIButton()
        bt.setImage(UIImage(systemName: "xmark"), for: .normal)
//        bt.setTitle("Cancel", for: .normal)
        bt.tintColor = .white
        bt.backgroundColor = .clear
        bt.translatesAutoresizingMaskIntoConstraints = false
        return bt
    }()
    
    let viTest: UIView = {
        let vi = UIView()
        vi.backgroundColor = UIColor.white
        vi.translatesAutoresizingMaskIntoConstraints = false
        return vi
    }()
    
    let viBlackView: UIView = {
        let vi = UIView()
        vi.backgroundColor = UIColor(white: 0, alpha: 0.5)
        vi.translatesAutoresizingMaskIntoConstraints = false
        return vi
    }()
    
    let viBodyTest: BodyActionTest = {
        let vi = BodyActionTest()
        vi.backgroundColor = .white
        vi.translatesAutoresizingMaskIntoConstraints = false
        return vi
    }()
    
    let viFaceCorp: UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        vi.layer.borderWidth = 2
        vi.layer.borderColor = UIColor.gray.cgColor
        return vi
    }()
}

// MARK: -Extensions

extension CameraVC: CalculationTestViewDelegate {
    func equationSolved() {
        takePhoto()
    }
}

extension CameraVC: ColorTestVCDelegate {
    func colorChoosed() {
        takePhoto()
    }
}

extension CameraVC: CameraServiceDelegate {
    func didStartFraming(faceObservations: [VNFaceObservation]) {
        var maxX: CGFloat?
        var midX: CGFloat?
        var minX: CGFloat?
                
        for faceobservation in faceObservations {
            
            let bounding = faceobservation.boundingBox
            
            let transform = CGAffineTransform(translationX: bounding.origin.x, y: bounding.origin.y).scaledBy(x: self.faceCropFrame.width, y: self.faceCropFrame.height)
            
            let topLeft = CGPoint(x: bounding.origin.x, y: bounding.origin.y)
            let topRight = CGPoint(x: bounding.maxX, y: bounding.minY)
            let bottomLeft = CGPoint(x: bounding.minX, y: bounding.maxY)
//            let bottomRight = CGPoint(x: bounding.maxX, y: bounding.maxY)
            let convertedTopLeft = topLeft.applying(transform)
            let convertedTopRight = topRight.applying(transform)
            let convertedBottomLeft = bottomLeft.applying(transform)
//            let convertedBottomRight = bottomRight.applying(transform)

            
            if convertedTopLeft.x >= self.faceCropFrame.origin.x &&
                convertedTopRight.x <= self.faceCropFrame.maxX &&
//                convertedTopLeft.y >= self.faceCropFrame.origin.y &&
                convertedBottomLeft.y <= self.faceCropFrame.maxY {
//            if self.faceCropFrame.contains(rect){
                print("Succeded")
                if let landmarks = faceobservation.landmarks {
                    minX = convertedTopLeft.x
//                        print("minX \(minX)")
                    maxX = convertedTopRight.x
//                        print("maxX \(maxX)")
                    if let medianLine: VNFaceLandmarkRegion2D = landmarks.medianLine, medianLine.normalizedPoints.count > 0{
                        let convertedMid = medianLine.normalizedPoints[0].applying(transform)
                        midX = convertedMid.x
//                        print("midX \(midX)")
                    }
                }
                if let midX = midX, let minX = minX, let maxX = maxX{
                    if testType == "Turn your face to the right" {
                        if midX >= maxX - 70 {
                            cameraService.startFraming = false
//                            print("Max \(maxX), mid \(midX), min \(minX)")
//                            print("done")
                            takePhoto()
                        }
                    } else if testType == "Turn your face to the left" {
                        if midX <= minX + 20 {
                            cameraService.startFraming = false
//                            print("Max \(maxX), mid \(midX), min \(minX)")
//                            print("done")
                            takePhoto()
                        }
                    }
                }
            }
        }
    }
}
