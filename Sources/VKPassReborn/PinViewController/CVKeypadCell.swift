//
//  CVKeypadCell.swift
//  CVPasscodeController
//
//  Created by 杨弘宇 on 16/7/6.
//  Copyright © 2016年 Cyandev. All rights reserved.
//

import UIKit
import AudioToolbox

class CVKeypadCell: UIControl {

    var text: String?
    var color: UIColor!
    var interfaceVisualEffect: UIVisualEffect!
    
    private var vibrancyView: UIVisualEffectView!
    private var outlineView: UIView!
    private var label: UILabel!
    
    private var outlineLayer: CAShapeLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        vibrancyView = UIVisualEffectView(effect: nil)
        outlineView = UIView()
        label = UILabel()
        
        outlineLayer = CAShapeLayer()
        outlineLayer.lineWidth = 2
        outlineLayer.strokeColor = UIColor.white.cgColor
        outlineLayer.fillColor = nil
        
        outlineView.layer.addSublayer(outlineLayer)
        
        vibrancyView.contentView.addSubview(outlineView)
        
        label.font = UIFont.systemFont(ofSize: 32, weight: UIFont.Weight.thin)
        label.textAlignment = .center
        
        addSubview(vibrancyView)
        addSubview(label)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        vibrancyView.frame = bounds
        outlineView.frame = vibrancyView.bounds
        outlineLayer.frame = outlineView.bounds.insetBy(dx: 5, dy: 5).offsetBy(dx: -2.5, dy: -2.5)
        outlineLayer.path = CGPath(ellipseIn: outlineLayer.frame, transform: nil)
        
        label.frame = bounds
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        vibrancyView.effect = UIVibrancyEffect(blurEffect: interfaceVisualEffect as! UIBlurEffect)
        label.textColor = color
        label.text = text
    }
    
    // MARK: - Touch event handlers
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let distance = sqrt(pow(point.x - bounds.midX, 2) + pow(point.y - bounds.midY, 2))
        
        return distance <= bounds.width / 2.0 ? self : nil
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        AudioServicesPlaySystemSound(1104)
        
        setFillColor(color: UIColor.white, labelColor: UIColor.white, animated: false)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        setFillColor(color: UIColor.clear, labelColor: color, animated: true)
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        setFillColor(color: UIColor.clear, labelColor: color, animated: true)
    }
    
    // MARK: - Private methods
    
    func setFillColor(color: UIColor, labelColor: UIColor, animated: Bool) {
        CATransaction.begin()
        if animated {
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(0.6)
            CATransaction.setAnimationDuration(0.6)
            
            do {
                UIView.commitAnimations()
            }
        } else {
            CATransaction.setDisableActions(true)
        }
        outlineLayer.fillColor = color.cgColor
        label.textColor = labelColor
        CATransaction.commit()
    }

}
