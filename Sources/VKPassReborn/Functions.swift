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
    dictionaryStandart.append(.init(id: 1, configurator: .init(headerTitle: "Test section 1"), items: [
        .init(key: "test", value: "true", type: .standart)
    ]))
    dictionaryStandart.append(.init(id: 2, configurator: .init(headerTitle: "Test section 2", footerTitle: "Test section footer"), items: [
        .init(key: "test1", value: "true", type: .withSwitch)
    ]))
    return dictionaryStandart
}

func checkPreferences() {
    let fileManager = FileManager.default
    
    let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
    let path = documentDirectory.appending("/ru.anonz.vkpassreborn.plist")
    
    if(!fileManager.fileExists(atPath: path)) {
        createPreferencesPlist()
    } else {}
}

func createPreferencesPlist(save: Bool = false, new: [Group] = []) {
    let data : [Group] = defaultPreferences()
    
    let encoder = PropertyListEncoder()
    encoder.outputFormat = .xml
    do {
        let data = try encoder.encode(save ? new : data)
        try data.write(to: getPath())
    } catch {
        print(error)
    }
}

func removePreferences() {
    let fileManager = FileManager.default
    
    let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
    let path = documentDirectory.appending("/ru.anonz.vkpassreborn.plist")
    if(fileManager.fileExists(atPath: path)) {
        do {
            try fileManager.removeItem(atPath: path)
        } catch let error {
            print(error.localizedDescription)
        }
        createPreferencesPlist()
    } else {}
}

func changePreferences(_ group: Group, model: Group.Item) {
    var prefs = getDocumentsDictionary()
    if let row = prefs.firstIndex(where: {$0.id == group.id}) {
        if let item = prefs[row].items.firstIndex(where: { $0.key == model.key }) {
            prefs[row].items[item].value = model.value
        }
    }
    createPreferencesPlist(save: true, new: prefs)
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
