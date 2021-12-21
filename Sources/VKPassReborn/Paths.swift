//
//  File.swift
//  
//
//  Created by Alexander Orlov on 13.12.2021.
//

import Foundation
import UIKit

enum ItemType: String, Codable {
    case standart, subTitle, withSwitch, button, memory
}

struct GroupConfiguration: Codable, Hashable {
    var headerTitle: String?
//    var headerView: UIView?
    var footerTitle: String?
//    var footerView: UIView?
    
    enum CodingKeys: String, CodingKey {
        case headerTitle
        //case headerView
        case footerTitle
        //case footerView
    }
    
    init(headerTitle: String? = nil, /*headerView: UIView? = nil, */footerTitle: String? = nil/*, footerView: UIView? = nil*/) {
        self.headerTitle = headerTitle
//        self.headerView = headerView
        self.footerTitle = footerTitle
//        self.footerView = footerView
    }
}

struct Group: Codable, Hashable {
    struct Item: Codable, Hashable {
        var title: String?
        var image: String?
        var key: String
        var value: String
        var disabled: Bool
        var isHidden: Bool
        var type: ItemType
        
        init(title: String? = nil,
             image: String? = nil,
             key: String? = nil,
             value: String? = nil,
             disabled: Bool = false,
             isHidden: Bool = false,
             type: ItemType = .standart) {
            self.title = title
            self.image = image
            self.key = key ?? ""
            self.value = value ?? ""
            self.disabled = disabled
            self.isHidden = isHidden
            self.type = type
        }
    }
    var id: Int
    var configurator: GroupConfiguration
    var items: [Item]

    enum CodingKeys: String, CodingKey {
        case id
        case configurator
        case items
    }
    
    static func == (lhs: Group, rhs: Group) -> Bool {
        return lhs.id == rhs.id
    }
}

func getDocumentsDictionary() -> [Group] {
    
    let userDataURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("ru.anonz.vkpassreborn").appendingPathExtension("plist")
    do {
        let data = try Data(contentsOf: userDataURL)
        let decoder = PropertyListDecoder()
        return try decoder.decode([Group].self, from: data)
    } catch {
        // Handle error
        print(error)
        return [Group(id: 1, configurator: .init(), items: [])]
    }
}

func getPath() -> URL {
    let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
    let file = documents.appending("/ru.anonz.vkpassreborn.plist")
    return URL(fileURLWithPath: file)
}
