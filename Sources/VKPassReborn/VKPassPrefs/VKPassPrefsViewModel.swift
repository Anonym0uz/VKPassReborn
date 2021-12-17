//
//  VKPassPrefsViewModel.swift
//  
//
//  Created by Alexander Orlov on 13.12.2021.
//

import UIKit

protocol VKPassPrefsViewModelProtocol {
    
    var items: [Group]? { get }
    var needUpdate: (() -> Void)? { get set }
    
    func getData()
}

class VKPassPrefsViewModel: VKPassPrefsViewModelProtocol {
    
    var items: [Group]?
    var needUpdate: (() -> Void)?
    
    func getData() {
        self.items = getDocumentsDictionary()
        self.needUpdate?()
    }
}

extension NSObject {
    // create a static method to get a swift class for a string name
    class func swiftClassFromString(className: String) -> AnyClass! {
        // get the project name
        if let appName: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as! String? {
            // generate the full name of your class (take a look into your "YourProject-swift.h" file)
            let classStringName = "_TtC\(appName.utf16.count)\(appName)\(className.count)\(className)"
            // return the class!
            return NSClassFromString(classStringName)
        }
        return nil;
    }
}
