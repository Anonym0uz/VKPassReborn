//
//  File.swift
//  
//
//  Created by Alexander Orlov on 13.12.2021.
//

import Foundation
import UIKit

func defaultPreferences() -> [Group] {
    var dictionaryStandart = [Group]()
    dictionaryStandart.append(.init(items: [
        .init(key: "test", value: "true", type: .standart)
    ]))
    dictionaryStandart.append(.init(items: [
        .init(key: "test1", value: "true", type: .withSwitch)
    ]))
    return dictionaryStandart
}

func createPreferencesPlist() {
    let fileManager = FileManager.default
    
    let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
    let path = documentDirectory.appending("/ru.anonz.vkpassreborn.plist")
    
    if(!fileManager.fileExists(atPath: path)) {
        let data : [Group] = defaultPreferences()
        
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        do {
            let data = try encoder.encode(data)
            try data.write(to: getPath())
        } catch {
            // Handle error
            print(error)
        }
    } else {
        // Error handler
    }
}

func setupNavigationController(_ controller: UINavigationController!,
                               item: UINavigationItem,
                               navigationTitle: String = "",
                               hideBackText: Bool = true,
                               leftButtons: [UIBarButtonItem] = [],
                               rightButtons: [UIBarButtonItem] = []) -> Void {
    item.title = navigationTitle
    item.leftBarButtonItems = leftButtons
    item.rightBarButtonItems = rightButtons
    if hideBackText {
        item.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
    }
    controller.navigationBar.tintColor = .white
    controller.navigationBar.isTranslucent = false
    //        navigationController.navigationBar.barTintColor = UIColor.white
    controller.navigationBar.barTintColor = .black
    controller.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    controller.navigationBar.barStyle = .default
    controller.navigationBar.shadowImage = UIImage()
    if #available(iOS 15, *) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .black
        controller.navigationBar.standardAppearance = appearance
        controller.navigationBar.scrollEdgeAppearance = controller.navigationBar.standardAppearance
        controller.view.backgroundColor = .black
    }
}
