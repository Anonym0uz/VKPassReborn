import Orion
import VKPassRebornC
import UIKit

class AppDelegateHook: ClassHook<AppDelegate> {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        checkPreferences()
        let original = orig.application(application, didFinishLaunchingWithOptions: launchOptions)
        if getPasscode(username: "VKPassReborn") != nil {
            let settings = VKPassPrefsViewController(viewModel: .init())
            UIApplication.shared.keyWindow?.rootViewController?.present(settings.openPasscode(), animated: true, completion: nil)
        }
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
//@objcMembers class BaseSettingsController: VKMTableController {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 0 }
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { return UITableViewCell() }
//}
//@objcMembers class ModernSettingsController: BaseSettingsController {}
@objcMembers class VKSideMenuContainerController: VKMController {
    @objc dynamic func callMethod() {}
    dynamic func showSideMenu() {}
    dynamic func hideSideMenu() {}
}

//class VKBaseSettingsHook: ClassHook<BaseSettingsController> {
//    
//    func viewDidLoad() {
//        orig.viewDidLoad()
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if section == 2 {//section 2 is acc+design+app+privacy+blacklist
//            return orig.tableView(tableView, numberOfRowsInSection: section)
//        }
//        return orig.tableView(tableView, numberOfRowsInSection: section)
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if indexPath.section == 5 && indexPath.row == 1 {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "kek", for: indexPath)
//            cell.textLabel?.text = "kek"
//            return cell
//        } else {
//            return orig.tableView(tableView, cellForRowAt: indexPath)
//        }
//    }
//    
//}

class VKSideHook: ClassHook<VKSideMenuContainerController> {
    
    func hideSideMenu() {
        orig.hideSideMenu()
    }
    func showSideMenu() {
        orig.showSideMenu()
    }
    func callMethod() {
        orig.hideSideMenu()
    }
}

final class VKPassCell: VKMCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)!
    }
}

@objcMembers class VKMLiveController : VKMTableController {}
//@objcMembers class _TtC3vkm22PeerListViewController : UITableViewController {
//    override func numberOfSections(in tableView: UITableView) -> Int { 0 }
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { return UITableViewCell() }
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 0 }
//    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? { return nil }
//}

class PeerHook: ClassHook<_TtC3vkm22PeerListViewController> {
    func viewDidAppear(_ animated: Bool) {
        orig.viewDidAppear(animated)
        if getPasscode(username: "VKPassReborn") != nil && (getPreferences(for: "useChat") as NSString).boolValue {
            let settings = VKPassPrefsViewController(viewModel: .init())
            UIApplication.shared.keyWindow?.rootViewController?.present(settings.openPasscode(), animated: true, completion: nil)
        }
    }
}

class SideMenuHook: ClassHook<SideMenuViewController> {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 50
        } else {
            return orig.tableView(tableView, heightForHeaderInSection: section)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let v = VKPassView()
            v.setHooked(orig.target)
            return v
        }
        return orig.tableView(tableView, viewForHeaderInSection: section)
    }
}

final class VKPassView: UIView {
    
    var actionButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .clear
        }
        return view
    }()
    
    var imageIcon: UIImageView = {
        let img = UIImageView()
        if #available(iOS 15.0, *) {
            img.tintColor = .systemCyan
        } else {
            if #available(iOS 13.0, *) {
                img.tintColor = .systemBlue
            } else {
                img.tintColor = .cyan
            }
        }
        img.translatesAutoresizingMaskIntoConstraints = false
        img.contentMode = .scaleAspectFill
        img.image = UIImage(named: "\(tweakResourceFolder)/vkpass_icon")?.withRenderingMode(.alwaysTemplate)
        return img
    }()
    
    var titleLable: UILabel = {
        let label = UILabel()
        label.text = "VKPassReborn"
        if #available(iOS 13.0, *) {
            label.textColor = .label
        } else {
            label.textColor = .black
        }
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var hookedClass: SideMenuHook.Target?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(contentView)
        contentView.addSubview(actionButton)
        contentView.addSubview(imageIcon)
        contentView.addSubview(titleLable)
        actionButton.addTarget(self, action: #selector(openVKPass), for: .touchUpInside)
        bringSubviewToFront(actionButton)
        addConstraints([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leftAnchor.constraint(equalTo: leftAnchor),
            contentView.rightAnchor.constraint(equalTo: rightAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        contentView.addConstraints([
            
            imageIcon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            imageIcon.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 18),
            imageIcon.widthAnchor.constraint(equalToConstant: 25),
            imageIcon.heightAnchor.constraint(equalToConstant: 25),
            
            titleLable.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLable.leftAnchor.constraint(equalTo: imageIcon.rightAnchor, constant: 15),
            titleLable.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -15),
            
            actionButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            actionButton.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            actionButton.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            actionButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func setHooked(_ hookedClass: SideMenuHook.Target) {
        self.hookedClass = hookedClass
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func openVKPass() {
        let settingsVC = VKPassPrefsViewController(viewModel: .init())
        let navCtrl = VANavigationController(rootViewController: settingsVC)
        hookedClass?.delegate.sideMenuViewController(hookedClass, requirePresent: navCtrl, modal: true)
    }
}

class UserWallControllerHook: ClassHook<UserWallController> {
}

class AboutViewControllerHook: ClassHook<AboutViewController> {
    
}

//class ModernSettingsHook: ClassHook<ModernSettingsController> {
//
//    var vkpassCell: VKMCell! = {
//        let cell = VKMCell()
//        return cell
//    }()
//
////    var tableView: UITableView?
//
//    func viewDidLoad() {
//        orig.viewDidLoad()
//    }
//}

class ChatControllerHook: ClassHook<ChatController> {
}

class AudioSubscriptionCheckerHook: ClassHook<AudioSubscriptionChecker> {
    func updateExpiresDate(_ arg1: Int64, musicSubscriptionPurchasedDuringSession: Bool) {
        if (getPreferences(for: "subscriptionActive") as NSString).boolValue {
            orig.updateExpiresDate(1, musicSubscriptionPurchasedDuringSession: musicSubscriptionPurchasedDuringSession)
        } else {
            orig.updateExpiresDate(arg1, musicSubscriptionPurchasedDuringSession: musicSubscriptionPurchasedDuringSession)
        }
    }
    
    func subscriptionActive() -> Bool {
        return (getPreferences(for: "subscriptionActive") as NSString).boolValue
    }
}
