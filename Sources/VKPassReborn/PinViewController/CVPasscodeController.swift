//
//  CVPasscodeController.swift
//  CVPasscodeController
//
//  Created by 杨弘宇 on 16/7/6.
//  Copyright © 2016年 Cyandev. All rights reserved.
//

import UIKit
import AudioToolbox

public enum CVPasscodeInterfaceStyle {
    case Dark
    case Light
}


public enum CVPasscodeInterfaceStringType {
    case InitialHint
    case WrongHint
    case Cancel
    case Backspace
}


public protocol CVPasscodeInterfaceStringProviding {
    func interfaceStringOfType(type: CVPasscodeInterfaceStringType, forPasscodeController controller: CVPasscodeController) -> String
}


public protocol CVPasscodeEvaluating {
    // Return the number of digits in this method to initialize the digit indicator and help the controller judge the end of user inputting.
    func numberOfDigitsInPasscodeForPasscodeController(controller: CVPasscodeController) -> Int
    
    // This will be called after the designated digits finished being inputted, if true was returned then the controller will dismiss, otherwise, the device will vibrate and there will be some visual feedback to tell user the passcode was wrong.
    func evaluatePasscode(passcode: String, forPasscodeController controller: CVPasscodeController) -> Bool
    
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
    
    public init(interfaceStyle: CVPasscodeInterfaceStyle) {
        self.interfaceStyle = interfaceStyle
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.interfaceStyle = .Dark
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.interfaceStyle = .Dark
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
        hintLabel.textColor = interfaceStyle == .Dark ? whiteColor : blackColor
        hintLabel.text = interfaceStringProvider?.interfaceStringOfType(type: .InitialHint, forPasscodeController: self) ?? "Enter Passcode"
        
        backspaceButton.tintColor = interfaceStyle == .Dark ? whiteColor : blackColor
        backspaceButton.translatesAutoresizingMaskIntoConstraints = false
        backspaceButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        updateBackspaceButtonTitle()
        
        let interfaceVisualEffect = UIBlurEffect(style: self.interfaceStyle == .Dark ? .dark : .extraLight)
        
        keypad.translatesAutoresizingMaskIntoConstraints = false
        keypad.keypadCells.forEach { cell in
            cell.color = self.interfaceStyle == .Dark ? whiteColor : blackColor
            cell.interfaceVisualEffect = interfaceVisualEffect
            cell.addTarget(self, action: #selector(cellDidTap(sender:)), for: .touchDown)
        }
        
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.interfaceVisualEffect = interfaceVisualEffect
        
        view.addSubview(hintLabel)
        view.addSubview(backspaceButton)
        view.addSubview(keypad)
        view.addSubview(indicator)
        
        view.addConstraint(NSLayoutConstraint(
            item: hintLabel,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: view,
            attribute: .centerY,
            multiplier: 1.0,
            constant: -230)
        )
        
        view.addConstraint(NSLayoutConstraint(
            item: hintLabel,
            attribute: .centerX,
            relatedBy: .equal,
            toItem: view,
            attribute: .centerX,
            multiplier: 1.0,
            constant: 0)
        )
        
        view.addConstraint(NSLayoutConstraint(
            item: backspaceButton,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: view,
            attribute: .bottom,
            multiplier: 1.0,
            constant: -35)
        )
        
        view.addConstraint(NSLayoutConstraint(
            item: backspaceButton,
            attribute: .centerX,
            relatedBy: .equal,
            toItem: view,
            attribute: .centerX,
            multiplier: 1.0,
            constant: 0)
        )
        
        view.addConstraint(NSLayoutConstraint(
            item: keypad,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: view,
            attribute: .centerY,
            multiplier: 1.0,
            constant: 50)
        )
        
        view.addConstraint(NSLayoutConstraint(
            item: keypad,
            attribute: .centerX,
            relatedBy: .equal,
            toItem: view,
            attribute: .centerX,
            multiplier: 1.0,
            constant: 0)
        )
        
        view.addConstraint(NSLayoutConstraint(
            item: keypad,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1.0,
            constant: 275)
        )
        
        view.addConstraint(NSLayoutConstraint(
            item: keypad,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1.0,
            constant: 375)
        )
        
        view.addConstraint(NSLayoutConstraint(
            item: indicator,
            attribute: .top,
            relatedBy: .equal,
            toItem: hintLabel,
            attribute: .bottom,
            multiplier: 1.0,
            constant: 15)
        )
        
        view.addConstraint(NSLayoutConstraint(
            item: indicator,
            attribute: .centerX,
            relatedBy: .equal,
            toItem: view,
            attribute: .centerX,
            multiplier: 1.0,
            constant: 0)
        )
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
        if currentInput.count == 0 {
            title = interfaceStringProvider?.interfaceStringOfType(type: .Cancel, forPasscodeController: self) ?? "Cancel"
        } else {
            title = interfaceStringProvider?.interfaceStringOfType(type: .Backspace, forPasscodeController: self) ?? "Delete"
        }
        
        backspaceButton.setTitle(title, for: .normal)
    }
    
    @objc func cellDidTap(sender: AnyObject?) {
        if evaluating {
            return
        }
        
        if let cell = sender as? CVKeypadCell {
            let digitString = cell.text!
            currentInput += digitString
            indicator.setNumberOfFilledDot(number: currentInput.count)
            updateBackspaceButtonTitle()
            if currentInput.count == numberOfDigits {
                evaluating = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                    self.evaluatePasscode()
                    self.evaluating = false
                })
            }
        }
    }
    
    @objc private func cancel() {
        if currentInput.count == 0 {
            dismiss(animated: true, completion: nil)
        } else {
            currentInput = currentInput.substring(to: currentInput.endIndex)
            indicator.setNumberOfFilledDot(number: currentInput.count)
            updateBackspaceButtonTitle()
        }
    }

    private func evaluatePasscode() {
        if passcodeEvaluator.evaluatePasscode(passcode: currentInput, forPasscodeController: self) {
            dismiss(animated: true, completion: nil)
        } else {
            currentInput = ""
            indicator.setNumberOfFilledDot(number: 0)
            updateBackspaceButtonTitle()
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
