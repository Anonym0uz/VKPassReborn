//
//  CustomAlert.swift
//  
//
//  Created by Alexander Orlov on 21.12.2021.
//

import Foundation
import UIKit

func createAlertAction(title: String,
                       style: UIAlertAction.Style = .default,
                       handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
    UIAlertAction(title: title, style: style, handler: handler)
}

func createVKPassAlert(message: String? = nil,
                       type: UIAlertController.Style = .alert,
                       buttons: [UIAlertAction] = [],
                       cancelTitle: String = "OK",
                       cancelHandler: ((UIAlertAction) -> Void)? = nil) -> UIAlertController {
    let alert = UIAlertController(title: "VKPassReborn", message: message, preferredStyle: type)
    if buttons.count > 0 {
        for button in buttons {
            alert.addAction(button)
        }
    }
    alert.addAction(.init(title: cancelTitle, style: .cancel, handler: cancelHandler))
    return alert
}
