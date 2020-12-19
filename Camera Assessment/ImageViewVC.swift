//
//  ImageViewVC.swift
//  Camera Assessment
//
//  Created by Abo-Aljoud94 on 12/17/20.
//

import UIKit

class ImageViewVC: UIViewController {
    
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(ivMain)
        ivMain.frame = view.frame
        ivMain.image = self.image ?? nil
        ivMain.contentMode = .scaleAspectFit
        
        
    }
    
    let ivMain: UIImageView = {
        let iv = UIImageView()
        return iv
    }()
}
