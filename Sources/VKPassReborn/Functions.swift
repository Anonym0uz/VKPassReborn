//
//  File.swift
//  
//
//  Created by Alexander Orlov on 13.12.2021.
//

import Foundation
import UIKit
import os.log

let tweakResourceFolder: String = "/private/var/mobile/Library/Application Support/ru.anonz.vkpassreborn/Documents/ru.anonz.vkpassreborn.bundle"

func defaultPreferences() -> [Group] {
    var dictionaryStandart = [Group]()
    dictionaryStandart.append(.init(id: 1, configurator: .init(headerTitle: "Test section 1"), items: [
        .init(title: "Show alert on launch", key: "mainAlertEnabled", value: "false", type: .withSwitch),
        .init(title: "This is test button", key: "mainButton", type: .button),
        .init(title: "Cell maybe disabled", key: "test", disabled: Bool.random(), type: .standart),
        .init(title: "Cell maybe hidden", key: "test", isHidden: Bool.random(), type: .standart),
    ]))
    dictionaryStandart.append(.init(id: 2, configurator: .init(headerTitle: "Test section 2"), items: [
        .init(title: "Unlock music cache & subscription", key: "subscriptionActive", value: "false", type: .withSwitch)
    ]))
    return dictionaryStandart
}

func partialMigrations() {
    var prefs = getDocumentsDictionary()
    prefs.enumerated().forEach({ index, group in
        if group.configurator.headerTitle == "Test section 1" {
            prefs[index].configurator.headerTitle = "Main"
        }
        if group.configurator.headerTitle == "Test section 2" {
            prefs[index].configurator.headerTitle = "Other"
        }
    })
    checkElements(prefs)
}

private func checkElements(_ pref: [Group]) {
    let prefs = pref
    var newPrefs = prefs
    prefs.enumerated().forEach({ groupIndex, group in
        newPrefs[groupIndex].items.removeAll(where: { $0.key == "test" })
    })
    createPreferencesPlist(save: true, new: newPrefs)
}

func checkPreferences() {
    let fileManager = FileManager.default
    
    let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
    let path = documentDirectory.appending("/ru.anonz.vkpassreborn.plist")
    
    if(!fileManager.fileExists(atPath: path)) {
        createPreferencesPlist()
    } else {
        partialMigrations()
    }
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

//func saveImage() {
//    let documentsDirectoryURL = try! FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
//    // create a name for your image
//    let fileURL = documentsDirectoryURL.appendingPathComponent("Savedframe.png")
//
//    if !FileManager.default.fileExists(atPath: fileURL.path) {
//        do {
//            try UIImagePNGRepresentation(imageView.image!)!.write(to: fileURL)
//                print("Image Added Successfully")
//            } catch {
//                print(error)
//            }
//        } else {
//            print("Image Not Added")
//    }
//}

func changePreferences(_ group: Group, model: Group.Item) {
    var prefs = getDocumentsDictionary()
    if let row = prefs.firstIndex(where: {$0.id == group.id}) {
        if let item = prefs[row].items.firstIndex(where: { $0.key == model.key }) {
            prefs[row].items[item].value = model.value
        }
    }
    createPreferencesPlist(save: true, new: prefs)
}

func getPreferences(for key: String) -> String {
    let prefs = getDocumentsDictionary()
    var value = ""
    prefs.forEach({ group in
        group.items.forEach({ item in
            if item.key == key {
                value = item.value
                return
            }
        })
    })
    return value
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
