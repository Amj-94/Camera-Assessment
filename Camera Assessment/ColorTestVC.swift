//
//  ColorTestVC.swift
//  Camera Assessment
//
//  Created by Abo-Aljoud94 on 12/18/20.
//

import UIKit

protocol ColorTestVCDelegate {
    func colorChoosed()
}

class ColorTestVC: UIViewController {
    
    // MARK: -Properties
    
    var delegate: ColorTestVCDelegate!
    
    var selectedColor: UIColor?
    
    var colors = [UIColor.white, UIColor.red, UIColor.blue, UIColor.green, UIColor.systemPink, UIColor.orange]
    
    var selected: Int?
    
    var names = ["white", "red", "blue", "green", "pink", "orange"]
    
    // MARK: -Overrides
    
    override func viewDidLoad() {
        selectedColor = nil
        super.viewDidLoad()
        view.backgroundColor = .gray
        setUpLayOut()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let random = Int.random(in: 0...colors.count - 1)
        selected = random
//        selectedColor = colors[random]
        lbColor.text = "please tab the \(names[random]) button"
    }
    
    // MARK: -Selectors
    
    @objc func handleColorSelect(sender: UIButton) {
        print("tapped")
        if let selected = selected {
            if sender.tag == selected{
                self.dismiss(animated: true) {
                    self.delegate.colorChoosed()
                }
            }
        }
    }
    
    // MARK: -SetUpLayOut
    
    func setUpLayOut(){
        
        view.addSubview(lbQuestion)
        NSLayoutConstraint.activate([lbQuestion.topAnchor.constraint(equalTo: view.topAnchor, constant: 60), lbQuestion.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 50), lbQuestion.heightAnchor.constraint(equalToConstant: 60), lbQuestion.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -50)])

        view.addSubview(lbColor)
        NSLayoutConstraint.activate([lbColor.topAnchor.constraint(equalTo: lbQuestion.bottomAnchor, constant: 20), lbColor.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 50), lbColor.heightAnchor.constraint(equalToConstant: 60), lbColor.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -50)])
        
        view.addSubview(svFirst)
        NSLayoutConstraint.activate([svFirst.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10), svFirst.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -15), svFirst.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10), svFirst.heightAnchor.constraint(equalToConstant: 80)])
        
        view.addSubview(svSecond)
        NSLayoutConstraint.activate([svSecond.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10), svSecond.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -110), svSecond.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10), svSecond.heightAnchor.constraint(equalToConstant: 80)])
        
        view.addSubview(btFirstButton)
        btFirstButton.backgroundColor = colors[0]
        btFirstButton.tag = 0
        btFirstButton.addTarget(self, action: #selector(handleColorSelect(sender:)), for: .touchUpInside)
        
        view.addSubview(btSecondButton)
        btSecondButton.backgroundColor = colors[1]
        btSecondButton.tag = 1
        btSecondButton.addTarget(self, action: #selector(handleColorSelect(sender:)), for: .touchUpInside)
        
        view.addSubview(btThirdButton)
        btThirdButton.backgroundColor = colors[2]
        btThirdButton.tag = 2
        btThirdButton.addTarget(self, action: #selector(handleColorSelect(sender:)), for: .touchUpInside)
        
        view.addSubview(btFourthButton)
        btFourthButton.backgroundColor = colors[3]
        btFourthButton.tag = 3
        btFourthButton.addTarget(self, action: #selector(handleColorSelect(sender:)), for: .touchUpInside)

        view.addSubview(btFifthButton)
        btFifthButton.backgroundColor = colors[4]
        btFifthButton.tag = 4
        btFifthButton.addTarget(self, action: #selector(handleColorSelect(sender:)), for: .touchUpInside)

        view.addSubview(btSixthButton)
        btSixthButton.backgroundColor = colors[5]
        btSixthButton.tag = 5
        btSixthButton.addTarget(self, action: #selector(handleColorSelect(sender:)), for: .touchUpInside)
        
        svFirst.addArrangedSubview(btFirstButton)
        svFirst.addArrangedSubview(btSecondButton)
        svFirst.addArrangedSubview(btThirdButton)
        svSecond.addArrangedSubview(btFourthButton)
        svSecond.addArrangedSubview(btFifthButton)
        svSecond.addArrangedSubview(btSixthButton)
    }
    
    // MARK: -Controls
    
    let lbQuestion: UILabel = {
        let lb = UILabel()
        lb.text = "In order to capture a photo you must select the Correct Color"
        lb.numberOfLines = 0
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    
    let lbColor: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    
    
    let svFirst: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 10
        sv.distribution = .fillEqually
//        sv.distribution = .equalSpacing
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    let svSecond: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 10
        sv.distribution = .fillEqually
//        sv.distribution = .equalSpacing
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    let btFirstButton: UIButton = {
        let bt = UIButton()
        bt.translatesAutoresizingMaskIntoConstraints = false
        return bt
    }()
    
    let btSecondButton: UIButton = {
        let bt = UIButton()
        bt.translatesAutoresizingMaskIntoConstraints = false
        return bt
    }()
    
    let btThirdButton: UIButton = {
        let bt = UIButton()
        bt.translatesAutoresizingMaskIntoConstraints = false
        return bt
    }()
    
    let btFourthButton: UIButton = {
        let bt = UIButton()
        bt.translatesAutoresizingMaskIntoConstraints = false
        return bt
    }()
    
    let btFifthButton: UIButton = {
        let bt = UIButton()
        bt.translatesAutoresizingMaskIntoConstraints = false
        return bt
    }()
    
    let btSixthButton: UIButton = {
        let bt = UIButton()
        bt.translatesAutoresizingMaskIntoConstraints = false
        return bt
    }()
}
