//
//  CVPasscodeController.swift
//  CVPasscodeController
//
//  Created by 杨弘宇 on 16/7/6.
//  Copyright © 2016年 Cyandev. All rights reserved.
//

import UIKit
import AudioToolbox
import LocalAuthentication

public enum CVPasscodeInterfaceStyle {
    case Dark
    case Light
}


public enum CVPasscodeInterfaceStringType {
    case New
    case InitialHint
    case WrongHint
    case Cancel
    case Backspace
}

public enum CVPasscodeInterfaceType {
    case new
    case check
    case change
    case delete
}


public protocol CVPasscodeInterfaceStringProviding {
    func interfaceStringOfType(type: CVPasscodeInterfaceStringType, forPasscodeController controller: CVPasscodeController) -> String
}


public protocol CVPasscodeEvaluating {
    // Return the number of digits in this method to initialize the digit indicator and help the controller judge the end of user inputting.
    func numberOfDigitsInPasscodeForPasscodeController(controller: CVPasscodeController) -> Int
    
    // This will be called after the designated digits finished being inputted, if true was returned then the controller will dismiss, otherwise, the device will vibrate and there will be some visual feedback to tell user the passcode was wrong.
    func evaluatePasscode(passcode: String, forPasscodeController controller: CVPasscodeController) -> Bool
    
    // This will be called after the designated digits finished being inputted, if true was returned then the controller will dismiss, otherwise, the device will vibrate and there will be some visual feedback to tell user the passcode was wrong.
    func evaluatePasscode(passcode: String, forPasscodeController controller: CVPasscodeController, type: CVPasscodeInterfaceType)
    
    // This will be called after user tapped the cancel button and controller has dismissed.
    func passcodeControllerDidCancel(controller: CVPasscodeController)
}


public class CVPasscodeController: UIViewController {

    private var hintLabel: UILabel!
    private var backspaceButton: UIButton!
    private var keypad: CVKeypad!
    private var indicator: CVPasscodeIndicator!
    
    private var currentInput = ""
    private var numberOfDigits: Int!
    private var evaluating = false
    
    public var interfaceStringProvider: CVPasscodeInterfaceStringProviding? // Set this to provide custom localized interface strings.
    public var passcodeEvaluator: CVPasscodeEvaluating! // This property must be set to tell the controller whether the passcode user input is valid.
    
    public let interfaceStyle: CVPasscodeInterfaceStyle // The getter of current interface style.
    private let passcodeType: CVPasscodeInterfaceType
    
    public var dismissHandler: ((CVPasscodeInterfaceType) -> Void)?
    
    public init(interfaceStyle: CVPasscodeInterfaceStyle, type: CVPasscodeInterfaceType = .check) {
        self.interfaceStyle = interfaceStyle
        self.passcodeType = type
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.interfaceStyle = .Dark
        self.passcodeType = .check
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.interfaceStyle = .Dark
        self.passcodeType = .check
        super.init(coder: aDecoder)
    }
    
    convenience init() {
        self.init(interfaceStyle: .Dark)
    }
    
    public override func loadView() {
        super.loadView()
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }
        assert(passcodeEvaluator != nil, "Evaluator must be set before controller presented.")
        numberOfDigits = passcodeEvaluator.numberOfDigitsInPasscodeForPasscodeController(controller: self)
        
        let blackColor = UIColor.black
        let whiteColor = UIColor.white
        
        hintLabel = UILabel()
        backspaceButton = UIButton(type: .system)
        keypad = CVKeypad()
        indicator = CVPasscodeIndicator(countOfDigits: numberOfDigits)
        
        hintLabel.translatesAutoresizingMaskIntoConstraints = false
        hintLabel.font = UIFont.systemFont(ofSize: 19)
        hintLabel.text = interfaceStringProvider?.interfaceStringOfType(type: (passcodeType != .new) ? .InitialHint : .New, forPasscodeController: self) ?? "Enter Passcode"
        
        if #available(iOS 13.0, *) {
            hintLabel.textColor = .label
            backspaceButton.tintColor = .label
        } else {
            hintLabel.textColor = interfaceStyle == .Dark ? whiteColor : blackColor
            backspaceButton.tintColor = interfaceStyle == .Dark ? whiteColor : blackColor
        }
        backspaceButton.translatesAutoresizingMaskIntoConstraints = false
        backspaceButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        
        let interfaceVisualEffect = UIBlurEffect(style: .prominent)
        
        keypad.translatesAutoresizingMaskIntoConstraints = false
        keypad.passcodeType = passcodeType
        keypad.action = { [weak self] button in
            guard let self = self else { return }
            self.cellDidTap(sender: button)
        }
        
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.interfaceVisualEffect = interfaceVisualEffect
        
        view.addSubview(hintLabel)
        view.addSubview(backspaceButton)
        view.addSubview(keypad)
        view.addSubview(indicator)
        
        view.addConstraints([
            
            keypad.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            keypad.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 50),
            keypad.widthAnchor.constraint(equalToConstant: 275),
            keypad.heightAnchor.constraint(equalToConstant: 375),
            
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicator.bottomAnchor.constraint(equalTo: keypad.topAnchor, constant: -30),
            
            hintLabel.bottomAnchor.constraint(equalTo: indicator.topAnchor, constant: -20),
            hintLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            backspaceButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backspaceButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -35)
        ])
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if getBiometricType() != .none && passcodeType == .check && (getPreferences(for: "useBiometrics") as NSString).boolValue {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.evaluteAuthentification()
//            }
        }
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return interfaceStyle == .Dark ? .lightContent : .default
    }
    
    public override var shouldAutorotate: Bool {
        return false
    }
    
    public override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    // MARK: - Private methods
    
    private func updateBackspaceButtonTitle() {
        let title: String
        title = interfaceStringProvider?.interfaceStringOfType(type: .Cancel, forPasscodeController: self) ?? "Cancel"
        
        backspaceButton.setTitle(title, for: .normal)
    }
    
    private func updateHintText() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            UIView.transition(with: self.hintLabel,
                              duration: 0.25,
                              options: .transitionCrossDissolve) {
                self.hintLabel.text = self.interfaceStringProvider?.interfaceStringOfType(type: .InitialHint, forPasscodeController: self) ?? "Enter Passcode"
            } completion: { _ in }
        }
    }
    
    private func evaluteAuthentification() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "VKPassReborn"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                [weak self] success, authenticationError in
                
                DispatchQueue.main.async {
                    if success {
                        self?.authByBiometric()
                    } else {
                        self?.authByBiometric(false)
                    }
                }
            }
        } else {
            // no biometry
        }
    }
    
    private func authByBiometric(_ need: Bool = true) {
        if need {
            indicator.setNumberOfFilledDot(number: self.passcodeEvaluator.numberOfDigitsInPasscodeForPasscodeController(controller: self))
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.dismiss(animated: true, completion: nil)
//            }
        } else {
            currentInput = ""
            indicator.setNumberOfFilledDot(number: 0)
        }
    }
    
    @objc func cellDidTap(sender: AnyObject?) {
        if evaluating {
            return
        }
        
        if let cell = sender as? CVKeypadCell {
            
            if let imgName = cell.image {
                if imgName == "delete" {
                    cancel()
                    return
                }
                if imgName == "biometrics_face" || imgName == "biometrics_touch" {
                    passcodeType == .check ? evaluteAuthentification() : nil
                    return
                }
            }
            guard cell.text != nil else { return }
            let digitString = cell.text!
            currentInput += digitString
            indicator.setNumberOfFilledDot(number: currentInput.count)
            if currentInput.count == numberOfDigits {
                evaluating = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    self.evaluatePasscode()
                    self.evaluating = false
                })
            }
        }
    }
    
    @objc private func dismissView() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func cancel() {
        if currentInput.count == 0 {
            passcodeEvaluator.passcodeControllerDidCancel(controller: self)
        } else {
            currentInput = (currentInput.count != 1) ? currentInput.dropLast().description : ""
            indicator.setNumberOfFilledDot(number: currentInput.count)
        }
    }

    private func evaluatePasscode() {
        if passcodeType == .new {
            passcodeEvaluator.evaluatePasscode(passcode: currentInput, forPasscodeController: self, type: .new)
            dismiss(animated: true, completion: nil)
            return
        }
        if passcodeType == .delete {
            passcodeEvaluator.evaluatePasscode(passcode: currentInput, forPasscodeController: self, type: .delete)
            dismiss(animated: true, completion: nil)
            return
        }
        if passcodeType == .change {
            if passcodeEvaluator.evaluatePasscode(passcode: currentInput, forPasscodeController: self) {
//                dismiss(animated: true, completion: nil)
                dismiss(animated: false) {
                    self.dismissHandler?(.change)
                }
            }
            return
        }
        if passcodeEvaluator.evaluatePasscode(passcode: currentInput, forPasscodeController: self) {
            dismiss(animated: true, completion: nil)
        } else {
            currentInput = ""
            indicator.setNumberOfFilledDot(number: 0)
            updateHintText()
            performRetryFeedback()
        }
    }
    
    private func performRetryFeedback() {
        // First, shake the indicator view.
        let shakeAnimation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        shakeAnimation.values = [-20, 19, -18, 17, -15, 12, -6, 2, 0].map({ return NSNumber(value: $0) })
        shakeAnimation.duration = 0.6
        indicator.layer.add(shakeAnimation, forKey: "shake")
        
        // Second, set the hint label.
        UIView.transition(with: hintLabel, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.hintLabel.text = self.interfaceStringProvider?.interfaceStringOfType(type: .WrongHint, forPasscodeController: self) ?? "Wrong passcode, try again"
        }, completion: nil)
        
        // Third, vibrate the device.
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
    
}


extension CVPasscodeController: UIViewControllerTransitioningDelegate {
    
    class CVPasscodePresentationController: UIPresentationController {
        
        private var blurBackgroundView: UIVisualEffectView!
        
        override func presentationTransitionWillBegin() {
            super.presentationTransitionWillBegin()
            
            guard containerView != nil else {
                return
            }
            
            blurBackgroundView = UIVisualEffectView(effect: nil)
            blurBackgroundView.frame = containerView!.bounds
            
            containerView!.addSubview(blurBackgroundView)
            
            presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
                let interfaceStyle = (self.presentedViewController as! CVPasscodeController).interfaceStyle
                self.blurBackgroundView.effect = UIBlurEffect(style: interfaceStyle == .Dark ? .dark : .extraLight)
            }, completion: nil)
        }
        
        override func presentationTransitionDidEnd(_ completed: Bool) {
            super.presentationTransitionDidEnd(completed)
            
            if !completed && blurBackgroundView != nil {
                blurBackgroundView.removeFromSuperview()
            }
        }
        
        override func dismissalTransitionWillBegin() {
            super.dismissalTransitionWillBegin()
            
            guard blurBackgroundView != nil else {
                return
            }
            
            presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
                self.blurBackgroundView.effect = nil
            }, completion: nil)
        }
        
        override func dismissalTransitionDidEnd(_ completed: Bool) {
            super.dismissalTransitionDidEnd(completed)
            
            if completed && blurBackgroundView != nil {
                blurBackgroundView.removeFromSuperview()
            }
        }
        
    }
    
    public func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        return CVPasscodePresentationController(presentedViewController: presented, presenting: presenting)
    }
    
}

// MARK: Checker
func getBiometricType() -> BiometricType {
    let authContext = LAContext()
    if #available(iOS 11, *) {
        let _ = authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        switch(authContext.biometryType) {
        case .none:
            return .none
        case .touchID:
            return .touch
        case .faceID:
            return .face
        }
    } else {
        return authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) ? .touch : .none
    }
}

enum BiometricType {
    case none
    case touch
    case face
}
