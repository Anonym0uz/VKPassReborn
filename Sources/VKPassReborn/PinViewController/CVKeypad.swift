//
//  CVKeypad.swift
//  CVPasscodeController
//
//  Created by 杨弘宇 on 16/7/6.
//  Copyright © 2016年 Cyandev. All rights reserved.
//

import UIKit

class CVKeypad: UIView {

    private(set) var keypadCells = [CVKeypadCell]()
    private var biometricType: BiometricType = getBiometricType()
    var passcodeType: CVPasscodeInterfaceType = .new
    private var verticalStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.alignment = .center
        stack.spacing = 10
        return stack
    }()
    
    var action: ((CVKeypadCell) -> Void)?
    
    init() {
        super.init(frame: CGRect.zero)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        for i in 1...10 {
            let cell = CVKeypadCell(frame: CGRect(x: 0, y: 0, width: 85, height: 85))
            cell.text = "\(i == 10 ? 0 : i)"
            
//            addSubview(cell)
            keypadCells.append(cell)
        }
        addSubview(verticalStack)
        for i in 0..<4 {
            var newStack = UIStackView()
            newStack.translatesAutoresizingMaskIntoConstraints = false
            newStack.axis = .horizontal
            newStack.distribution = .fillEqually
            newStack.alignment = .fill
            newStack.spacing = 10
            var elements = [String]()
            if i == 0 {
                elements.append(contentsOf: ["1", "2", "3"])
            } else if i == 1 {
                elements.append(contentsOf: ["4", "5", "6"])
            } else if i == 2 {
                elements.append(contentsOf: ["7", "8", "9"])
            } else if i == 3 {
                elements.append(contentsOf: [(biometricType == .touch) ? "biometrics_touch" : "biometrics_face", "0", "delete"])
            }
            verticalStack.addArrangedSubview(addTo(stack: newStack, elements: elements, buttons: elements.count == 1))
        }
        
        addConstraints([
            verticalStack.topAnchor.constraint(equalTo: topAnchor),
            verticalStack.leftAnchor.constraint(equalTo: leftAnchor),
            verticalStack.rightAnchor.constraint(equalTo: rightAnchor),
            verticalStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
    }
    
    func addTo(stack: UIStackView, elements: [String], buttons: Bool = false) -> UIStackView {
        for i in 0..<elements.count {
            let cell = CVKeypadCell(frame: CGRect(x: 0, y: 0, width: 85, height: 85))
            cell.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            cell.translatesAutoresizingMaskIntoConstraints = false
            cell.text = elements[i]
            if elements[i] == "biometrics_touch" || elements[i] == "biometrics_face" || elements[i] == "delete" {
                cell.text = ""
                cell.image = elements[i]
            }
            stack.addArrangedSubview(cell)
            stack.addConstraints([
                cell.widthAnchor.constraint(equalToConstant: 85)
            ])
            if (elements[i] == "biometrics_touch" || elements[i] == "biometrics_face") &&
                (biometricType == .none || (getPreferences(for: "useBiometrics") as NSString).boolValue == false) {
                cell.outlineNeed(false)
                cell.image = nil
                cell.text = nil
            }
        }
        return stack
    }
    
    @objc func buttonTapped(_ sender: CVKeypadCell) {
        action?(sender)
    }
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//
//        var col = 0
//        var row = 0
//
//        for cell in keypadCells {
//            cell.frame.origin = CGPoint(x: col * 100, y: row * 100)
//
//            col += 1
//            if col > 2 {
//                row += 1
//                col = row == 3 ? 1 : 0
//            }
//        }
//    }

}
