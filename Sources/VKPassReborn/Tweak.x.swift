import Orion
import VKPassRebornC
import UIKit

class AppDelegateHook: ClassHook<AppDelegate> {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let original = orig.application(application, didFinishLaunchingWithOptions: nil)
        let alert = UIAlertController(title: "Test", message: "Kekekekeke", preferredStyle: .alert)
        alert.addAction(.init(title: "Test2", style: .default, handler: { _ in
            let testClass = TestViewController()
            let navCtrl = VANavigationController(rootViewController: VKPassPrefsViewController(viewModel: .init()))
            UIApplication.shared.keyWindow?.rootViewController?.present(navCtrl, animated: true, completion: nil)
        }))
        alert.addAction(.init(title: "Test", style: .cancel, handler: nil))
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        return original
    }
}

@objcMembers class VANavigationController: UINavigationController {}

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
