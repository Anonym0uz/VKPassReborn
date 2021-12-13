//
//  File.swift
//  
//
//  Created by Alexander Orlov on 13.12.2021.
//

import Foundation

enum ItemType: String, Codable {
    case standart, subTitle, withSwitch, button
}

struct Group: Codable {
    struct Item: Codable {
        var image: String?
        var key: String
        var value: String
        var type: ItemType
        
        init(image: String? = nil, key: String? = nil, value: String? = nil, type: ItemType = .standart) {
            self.image = image
            self.key = key ?? ""
            self.value = value ?? ""
            self.type = type
        }
    }

    var items: [Item]

    enum CodingKeys: String, CodingKey {
        case items
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
        return [Group(items: [])]
    }
}

func getPath() -> URL {
    let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
    let file = documents.appending("/ru.anonz.vkpassreborn.plist")
    return URL(fileURLWithPath: file)
}
