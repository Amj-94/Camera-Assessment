//
//  CameraVC.swift
//  Camera Assessment
//
//  Created by Abo-Aljoud94 on 12/17/20.
//

import UIKit
import AVFoundation

class CameraVC: UIViewController {
    
    // MARK: -Properties
    
    var captureSession = AVCaptureSession()
    
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?
    
    var photoOutPut = AVCapturePhotoOutput()
    
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    // MARK: -Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLayOut()
        setUpCaptureSession()
        setUpDevice()
        setUpInputOutput()
        setUpPreviewLayOut()
        startRunningCaptureSession()
    }
    
    // MARK: -Funcs
    
    func setUpCaptureSession(){
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
    }
    
    func setUpDevice(){
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: .video, position: AVCaptureDevice.Position.unspecified)
        let devices = deviceDiscoverySession.devices
        for device in devices {
            if device.position == .back {
                backCamera = device
            } else if device.position == .front {
                frontCamera = device
            }
        }
        currentCamera = frontCamera
//        currentCamera = backCamera
        
    }
    
    func setUpInputOutput(){
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)
            captureSession.addInput(captureDeviceInput)
            photoOutPut.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
            if captureSession.canAddOutput(photoOutPut){
                captureSession.addOutput(photoOutPut)
            }
        } catch let error {
            print(error)
        }
    }
    
    func setUpPreviewLayOut(){
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.connection?.videoOrientation = .portrait
        cameraPreviewLayer?.frame = view.frame
        self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
        
    }
    
    func startRunningCaptureSession(){
        captureSession.startRunning()
    }
    
    func addBodyActionView(){
        let bodyActions = ["Blink your right eye 2 times", "Blink you left eye 3 times", "touch your nose with your tounge"]
        let random = Int.random(in: 0...2)
        let dialog = UIAlertController(title:"Prove you are not a robot", message: bodyActions[random], preferredStyle: .alert)
        let okAction = UIAlertAction(title:"OK", style: .default, handler: {(alert:UIAlertAction!)-> Void in
            self.takePhoto()
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
        sleep(2)
        let shutterView = UIView(frame: cameraPreviewLayer?.frame ?? .zero)
        shutterView.backgroundColor = UIColor.black
        view.addSubview(shutterView)
        UIView.animate(withDuration: 0.3, animations: {
            shutterView.alpha = 0
        }, completion: { (_) in
            shutterView.removeFromSuperview()
            let settings = AVCapturePhotoSettings()
            self.photoOutPut.capturePhoto(with: settings, delegate: self)
        })
    }
    
    // MARK: -Selectors
    
    @objc func handleCloseButton(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleCapturePhoto(sender: UIButton) {
//        addColorTest()
//        addCalculationTest()
//        addBodyActionView()
        let random = Int.random(in: 1...3)
        switch random {
        case 1:
            addBodyActionView()
        case 2:
            addColorTest()
        case 3:
            addCalculationTest()

        default: break

        }
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
}

// MARK: -Extensions
extension CameraVC: AVCapturePhotoCaptureDelegate {
    
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        if let error = error {
            print("trigger error \(error)")
        }
        
        if let imageDate = photo.fileDataRepresentation() {
            let image = UIImage(data: imageDate)
            let vc = ImageViewVC()
            vc.image = image
            present(vc, animated: true, completion: nil)
        }
    }
}

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
