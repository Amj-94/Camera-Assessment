//
//  ViewController.swift
//  Camera Assessment
//
//  Created by Abo-Aljoud94 on 12/17/20.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(btCamera)
        NSLayoutConstraint.activate([btCamera.centerXAnchor.constraint(equalTo: view.centerXAnchor), btCamera.centerYAnchor.constraint(equalTo: view.centerYAnchor), btCamera.widthAnchor.constraint(equalToConstant: 85), btCamera.heightAnchor.constraint(equalToConstant: 50)])
        btCamera.addTarget(self, action: #selector(handleCamera(sender:)), for: .touchUpInside)
        btCamera.setTitle("Capture", for: .normal)
    }

    @objc func handleCamera(sender: UIButton) {
        let vc = CameraVC()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }

    let btCamera: UIButton = {
        let bt = UIButton()
        bt.setTitleColor(.black, for: .normal)
        bt.layer.borderWidth = 1
        bt.layer.borderColor = UIColor.gray.cgColor
//        bt.backgroundColor = .red
        bt.translatesAutoresizingMaskIntoConstraints = false
        return bt
    }()
}
