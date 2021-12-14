import Orion
import VKPassRebornC
import UIKit

class AppDelegateHook: ClassHook<AppDelegate> {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        checkPreferences()
        let original = orig.application(application, didFinishLaunchingWithOptions: launchOptions)
        let alert = UIAlertController(title: "Test", message: "Kekekekeke", preferredStyle: .alert)
        alert.addAction(.init(title: "Test2", style: .default, handler: { _ in
            let navCtrl = VANavigationController(rootViewController: VKPassPrefsViewController(viewModel: .init()))
            UIApplication.shared.keyWindow?.rootViewController?.present(navCtrl, animated: true, completion: nil)
        }))
        alert.addAction(.init(title: "Test", style: .cancel, handler: nil))
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        return original
    }
}

@objcMembers class VANavigationController: UINavigationController {}
@objcMembers class VKMCell: UITableViewCell {}
@objcMembers class PassportCardCell: UITableViewCell {}
@objcMembers class VAViewController: UIViewController {}
@objcMembers class VKController: VAViewController {}
@objcMembers class VKMController: VKController {}
@objcMembers class VKMScrollViewController: VKMController {}
@objcMembers class VKMTableController: VKMScrollViewController {}
@objcMembers class BaseSettingsController: VKMTableController {}
@objcMembers class ModernSettingsController: BaseSettingsController {}

final class VKPassCell: VKMCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)!
    }
}

class ModernSettingsHook: ClassHook<ModernSettingsController> {
    
    var vkpassCell: VKMCell! = {
        let cell = VKMCell()
        return cell
    }()
    
//    var tableView: UITableView?
    
    func viewDidLoad() {
        orig.viewDidLoad()
//        self.tableView?.register(VKPassCell.self, forCellReuseIdentifier: "String(describing: VKPassCell.self)")
    }
    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let original = orig.tableView(tableView, cellForRowAt: indexPath)
////        if let cell = tableView.dequeueReusableCell(withIdentifier: "String(describing: VKPassCell.self)", for: indexPath) as? VKPassCell {
//////            cell.setModel(groups?[indexPath.section].items[indexPath.row] ?? Group.Item())
////            return cell
////        }
//        
//        return original
//    }
}

class ChatControllerHook: ClassHook<ChatController> {
}

class AudioSubscriptionCheckerHook: ClassHook<AudioSubscriptionChecker> {
    func updateExpiresDate(_ arg1: Int64, musicSubscriptionPurchasedDuringSession: Bool) {
        orig.updateExpiresDate(1, musicSubscriptionPurchasedDuringSession: musicSubscriptionPurchasedDuringSession)
    }
    
    func subscriptionActive() -> Bool {
        return true
    }
}
