//
//  CalculationTestView.swift
//  Camera Assessment
//
//  Created by Abo-Aljoud94 on 12/18/20.
//

import UIKit

protocol CalculationTestViewDelegate {
    func equationSolved()
}

class CalculationTestView: UIViewController {
    
    // MARK: -Properties
    
    var answer: Int?
    
    var delegate: CalculationTestViewDelegate!
    
    // MARK: -Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray
        setUpLayOut()
//        let operations = ["+", "-", "*", "/"]
        let operations = ["+", "*"]
        let firstSide = Int.random(in: 1...10)
        let secondSide = Int.random(in: 1...10)
        let operation = operations[Int.random(in: 0...1)]
        lbEquation.text = ("\(firstSide) \(operation) \(secondSide)")
        switch operation {
        case "+":
            self.answer = firstSide + secondSide
//        case "-":
//            self.answer = firstSide - secondSide
        case "*":
            self.answer = firstSide * secondSide
//        case "/":
//            self.answer = firstSide / secondSide
            
        default:
            break
        }
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDissmiss)))
    }
    
    // MARK: -Selectors
    
    @objc func handleDissmiss(){
        view.endEditing(true)
    }
    
    @objc func handleSubmit(sender: UIButton) {
        tfAnswer.textColor = .black
        if let text = tfAnswer.text {
            if text == "\(answer ?? 0)"{
                self.dismiss(animated: true, completion: delegate.equationSolved)
            } else {
                tfAnswer.textColor = .red
            }
        }
    }
    
    // MARK: -SetUpLayOut
    
    func setUpLayOut(){
        
        view.addSubview(svMain)
        svMain.topAnchor.constraint(equalTo: view.topAnchor, constant: 15).isActive = true
        svMain.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(lbQuestion)
        lbQuestion.widthAnchor.constraint(equalToConstant: view.frame.width * 0.7).isActive = true
        lbQuestion.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        view.addSubview(lbEquation)
        lbEquation.widthAnchor.constraint(equalToConstant: view.frame.width * 0.7).isActive = true
        lbEquation.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        view.addSubview(tfAnswer)
        tfAnswer.widthAnchor.constraint(equalToConstant: view.frame.width * 0.7).isActive = true
        tfAnswer.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        view.addSubview(btSubmit)
        btSubmit.widthAnchor.constraint(equalToConstant: view.frame.width * 0.7).isActive = true
        btSubmit.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        btSubmit.addTarget(self, action: #selector(handleSubmit(sender:)), for: .touchUpInside)
        
        svMain.addArrangedSubview(lbQuestion)
        svMain.addArrangedSubview(lbEquation)
        svMain.addArrangedSubview(tfAnswer)
        svMain.addArrangedSubview(btSubmit)
    }
    
    // MARK: -Controls
    
    let svMain: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .fillEqually
        sv.spacing = 10
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    let lbQuestion: UILabel = {
        let lb = UILabel()
        lb.text = "In order to capture a photo you must solve this equation"
        lb.numberOfLines = 0
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    
    let lbEquation: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    
    let tfAnswer: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter your answer here"
        tf.keyboardType = .numberPad
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let btSubmit: UIButton = {
        let bt = UIButton()
        bt.setTitle("Submit", for: .normal)
        bt.layer.borderWidth = 1
        bt.layer.borderColor = UIColor.white.cgColor
        bt.translatesAutoresizingMaskIntoConstraints = false
        return bt
    }()
    
}
