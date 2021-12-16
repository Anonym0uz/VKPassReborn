import Orion
import VKPassRebornC
import UIKit

class AppDelegateHook: ClassHook<AppDelegate> {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        checkPreferences()
        let original = orig.application(application, didFinishLaunchingWithOptions: launchOptions)
        if (getPreferences(for: "mainAlertEnabled") as NSString).boolValue {
            let alert = UIAlertController(title: "TEST", message: "Wow \(getPreferences(for: "mainAlertEnabled"))", preferredStyle: .alert)
            alert.addAction(.init(title: "Close", style: .cancel, handler: nil))
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
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
@objcMembers class BaseSettingsController: VKMTableController {}
@objcMembers class ModernSettingsController: BaseSettingsController {}
@objcMembers class VKSideMenuContainerController: VKMController {
    @objc dynamic func callMethod() {}
    dynamic func showSideMenu() {}
    dynamic func hideSideMenu() {}
}

class VKSideHook: ClassHook<VKSideMenuContainerController> {
    
    func hideSideMenu() {
        orig.hideSideMenu()
    }
    func showSideMenu() {
        exit(0)
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
//@objcMembers class SideMenuViewController : VKMLiveController {
//    dynamic func setupBottomButton() {}
//    dynamic func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? { nil }
//    dynamic func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { 990 }
//}

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
        view.backgroundColor = .darkGray
        return view
    }()
    
    var titleLable: UILabel = {
        let label = UILabel()
        label.text = "VKPassReborn"
        label.textColor = .white
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var hookedClass: SideMenuHook.Target?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(contentView)
        contentView.addSubview(actionButton)
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
            titleLable.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLable.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 15),
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
        let navCtrl = VANavigationController(rootViewController: VKPassPrefsViewController(viewModel: .init()))
        hookedClass?.delegate.sideMenuViewController(hookedClass, requirePresent: navCtrl, modal: true)
    }
}

class UserWallControllerHook: ClassHook<UserWallController> {
    
    var navigationController: UINavigationController?
    var qrButton: UIBarButtonItem?
    
    func viewDidLoad() {
        orig.viewDidLoad()
        let originalQR = orig.qrButton
        if let originalQR = originalQR {
            navigationController?.navigationItem.rightBarButtonItems = []
        }
    }
}

class AboutViewControllerHook: ClassHook<AboutViewController> {
    
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
