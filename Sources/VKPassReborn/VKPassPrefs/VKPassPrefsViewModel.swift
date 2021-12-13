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
