import Preferences
import VKPassRebornPrefsC

class RootListController: PSListController {
    override var specifiers: NSMutableArray? {
        get {
            if let specifiers = value(forKey: "_specifiers") as? NSMutableArray {
                return specifiers
            } else {
                let specifiers = loadSpecifiers(fromPlistName: "Root", target: self)
                setValue(specifiers, forKey: "_specifiers")
                return specifiers
            }
        }
        set {
//            super.specifiers = newValue
            let dictionary = getDocumentsDictionary()
            dictionary.setValue(newValue, forKey: "_specifier")
            dictionary.write(to: getPath(), atomically: true)
        }
    }
}
