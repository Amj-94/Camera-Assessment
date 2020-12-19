//
//  BodyActiosTestVC.swift
//  Camera Assessment
//
//  Created by Abo-Aljoud94 on 12/18/20.
//

import UIKit

class BodyActionTest: UIView {

    var tests = ["Blink your right eye 2 times", "Blink you left eye 3 times", "touch your nose with your tounge"]

    override init(frame: CGRect) {
        super.init(frame: frame)


    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUpLayOut(){
        print(frame)
        let random = Int.random(in: 0...2)
        lbQuestion.text = tests[random]
        lbQuestion.backgroundColor = .red
        lbQuestion.textColor = .blue
        addSubview(lbQuestion)
//        lbQuestion.frame = CGRect(x: 50, y: 50, width: 50, height: 20)
//        NSLayoutConstraint.activate([lbQuestion.centerXAnchor.constraint(equalTo: centerXAnchor), lbQuestion.centerYAnchor.constraint(equalTo: centerYAnchor), lbQuestion.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.75), lbQuestion.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.5)])
        NSLayoutConstraint.activate([lbQuestion.centerXAnchor.constraint(equalTo: centerXAnchor), lbQuestion.centerYAnchor.constraint(equalTo: centerYAnchor), lbQuestion.widthAnchor.constraint(equalToConstant: 100), lbQuestion.heightAnchor.constraint(equalToConstant: 100)])
    }

    let lbQuestion: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 12)
        lb.textColor = .black
        lb.numberOfLines = 0
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
}



//class BodyActionTest: NSObject {
//
//    var tests = ["Blink your right eye 2 times", "Blink you left eye 3 times", "touch your nose with your tounge"]
//
//    override init() {
//        super.init()
//
//    }
//
//    func setUpLayOut(){
//        DispatchQueue.main.async {
//            if let window = UIApplication.shared.windows.first {
//                self.blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
//
//                window.addSubview(self.blackView)
//                window.addSubview(self.lbQuestion)
//                let random = Int.random(in: 0...2)
//                self.lbQuestion.text = self.tests[random]
//
//                self.lbQuestion.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width * 0.6, height: window.frame.height * 2/8)
//
//
//                self.blackView.frame = window.frame
//                self.blackView.alpha = 0
//                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
//
//                    self.blackView.alpha = 1
//
//                    self.lbQuestion.frame = CGRect(x: window.frame.width * 0.2, y: window.frame.height * 4/8, width: window.frame.width * 0.6, height: window.frame.height * 2/8)
//
//                }, completion: nil)
//                sleep(6)
//                UIView.animate(withDuration: 0.5) {
//                    self.blackView.alpha = 0
//                    self.lbQuestion.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width * 0.6, height: window.frame.height * 2/8)
//                }
//            }
//
//        }
//    }
//
//    let blackView = UIView()
//
//    let lbQuestion: UILabel = {
//        let lb = UILabel()
//        lb.font = UIFont.systemFont(ofSize: 12)
//        lb.textColor = .black
//        lb.numberOfLines = 0
//        lb.translatesAutoresizingMaskIntoConstraints = false
//        return lb
//    }()
//}
