//
//  VKPassPrefsViewController.swift
//  
//
//  Created by Alexander Orlov on 13.12.2021.
//

import UIKit
import Security

func storePasscodes(username: String, password: String) {
    let attributes: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: username,
        kSecValueData as String: password.data(using: .utf8)!,
    ]

    // Add user
    if SecItemAdd(attributes as CFDictionary, nil) == noErr {
        print("User saved successfully in the keychain")
        logt("User saved successfully in the keychain")
    } else {
        print("Something went wrong trying to save the user in the keychain")
        logt("Something went wrong trying to save the user in the keychain")
    }
}

func getPasscode(username: String) -> String? {
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: username,
        kSecMatchLimit as String: kSecMatchLimitOne,
        kSecReturnAttributes as String: true,
        kSecReturnData as String: true,
    ]
    var item: CFTypeRef?

    // Check if user exists in the keychain
    if SecItemCopyMatching(query as CFDictionary, &item) == noErr {
        // Extract result
        if let existingItem = item as? [String: Any],
           let username = existingItem[kSecAttrAccount as String] as? String,
           let passwordData = existingItem[kSecValueData as String] as? Data,
           let password = String(data: passwordData, encoding: .utf8)
        {
            print(username)
            print(password)
            logt(username)
            logt(password)
            return password
        }
    } else {
        print("Something went wrong trying to find the user in the keychain")
        logt("Something went wrong trying to find the user in the keychain")
        return nil
    }
    return nil
}

func updatePasscode(username: String, newPassword: String) {
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: username,
    ]

    // Set attributes for the new password
    let attributes: [String: Any] = [kSecValueData as String: newPassword.data(using: .utf8)!]

    // Find user and update
    if SecItemUpdate(query as CFDictionary, attributes as CFDictionary) == noErr {
        print("Password has changed")
        logt("Password has changed")
    } else {
        print("Something went wrong trying to update the password")
        logt("Something went wrong trying to update the password")
    }
}

func deletePasscode(username: String) {
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: username,
    ]

    // Find user and delete
    if SecItemDelete(query as CFDictionary) == noErr {
        print("User removed successfully from the keychain")
        logt("User removed successfully from the keychain")
    } else {
        print("Something went wrong trying to remove the user from the keychain")
        logt("Something went wrong trying to remove the user from the keychain")
    }
}

class VKPassPrefsViewController: UIViewController {
    
    var viewModel: VKPassPrefsViewModelProtocol
    var tableView: UITableView!
    var groups: [Group]?
    
    private var byApplication: Bool = false
    
    init(viewModel: VKPassPrefsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationController(navigationController,
                                  item: navigationItem,
                                  navigationTitle: "VKPassPreferences")
        let closeButton = UIBarButtonItem(title: "X", style: .plain, target: self, action: #selector(closeFunc))
        let reloadButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(reloadSettings))
        navigationItem.leftBarButtonItems = [closeButton]
        navigationItem.rightBarButtonItems = [reloadButton]
        view.backgroundColor = .white
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.register(BasePreferencesCell.self, forCellReuseIdentifier: "String(describing: BasePreferencesCell.self)")
        view.addSubview(tableView)
        view.addConstraints([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        bind()
        viewModel.getData()
    }
    
    func bind() {
        viewModel.needUpdate = { [weak self] in
            guard let self = self else { return }
            self.groups = self.viewModel.items?.enumerated().map({ index, group in
                var gr = group
                gr.items = gr.items.filter({ $0.isHidden == false })
                return Group(id: gr.id, configurator: gr.configurator, items: gr.items.filter({ $0.isHidden == false }))
            })
            self.tableView.reloadData()
        }
    }
    
    func openPasscode() -> CVPasscodeController {
        byApplication = true
        let passcodeController = CVPasscodeController(interfaceStyle: .Dark, type: .check)
        passcodeController.interfaceStringProvider = self
        passcodeController.passcodeEvaluator = self
        return passcodeController
    }
}

extension VKPassPrefsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if let groups = groups {
            return groups.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let groups = groups {
            return groups[section].items.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let sectionImage = UIImageView()
            sectionImage.contentMode = .scaleAspectFit
            sectionImage.image = UIImage(named: "\(tweakResourceFolder)/vkpassheader.png")
            sectionImage.clipsToBounds = true
            return sectionImage
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 160
        }
        return 30
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let groups = groups {
            if section == 0 {
                return nil
            }
            return groups[section].configurator.headerTitle
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if let groups = groups {
            return groups[section].configurator.footerTitle
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "String(describing: BasePreferencesCell.self)", for: indexPath) as? BasePreferencesCell {
            cell.setModel(groups?[indexPath.section].items[indexPath.row] ?? Group.Item(), group: groups?[indexPath.section] ?? Group(id: 1, configurator: .init(), items: []))
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let groups = groups {
            let item = groups[indexPath.section].items[indexPath.row]
            if item.type == .button || item.type == .standart {
                if item.key == "mainButton" {
                    let passcodeController = CVPasscodeController(interfaceStyle: .Dark, type: .new)
                    passcodeController.interfaceStringProvider = self
                    passcodeController.passcodeEvaluator = self
                    present(passcodeController, animated: true, completion: nil)
                }
                if item.key == "changePasscode" {
                    let passcodeController = CVPasscodeController(interfaceStyle: .Dark, type: .change)
                    passcodeController.interfaceStringProvider = self
                    passcodeController.passcodeEvaluator = self
                    passcodeController.dismissHandler = { [weak self] type in
                        guard let self = self else { return }
                        self.passcodeDismissed()
                    }
                    present(passcodeController, animated: true, completion: nil)
                }
                if item.key == "deletePasscode" {
                    let passcodeController = CVPasscodeController(interfaceStyle: .Dark, type: .delete)
                    passcodeController.interfaceStringProvider = self
                    passcodeController.passcodeEvaluator = self
                    present(passcodeController, animated: true, completion: nil)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
}

extension VKPassPrefsViewController: CVPasscodeEvaluating, CVPasscodeInterfaceStringProviding {
    func numberOfDigitsInPasscodeForPasscodeController(controller: CVPasscodeController) -> Int {
        return 6
    }
    
    func evaluatePasscode(passcode: String, forPasscodeController controller: CVPasscodeController, type: CVPasscodeInterfaceType) {
        switch type {
        case .new:
            storePasscodes(username: "VKPassReborn", password: passcode)
            getPasscode(username: "VKPassReborn")
            needChangePasscodePrefs(false)
//            var prefs = getDocumentsDictionary()
//            var pref = prefs.filter({ $0.id == 1 }).first
//            let pref2 = pref?.items.filter({ $0.key == "useBiometrics" || $0.key == "deletePasscode" || $0.key == "changePasscode" })
//            let pref3 = pref2?.enumerated().map({ index, model -> Group.Item in
//                var newModel = model
//                newModel.isHidden = false
//                return newModel
//            })
//            pref?.items = pref3 ?? []
        case .check:
            print("")
        case .change:
            deletePasscode(username: "VKPassReborn")
            needChangePasscodePrefs(true)
        case .delete:
            deletePasscode(username: "VKPassReborn")
            needChangePasscodePrefs(true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.present(createVKPassAlert(message: "Пароль удален"), animated: true)
            }
        }
        viewModel.getData()
    }
    
    func evaluatePasscode(passcode: String, forPasscodeController controller: CVPasscodeController) -> Bool {
        var returnVal = false
        guard let keychainPass = getPasscode(username: "VKPassReborn") else { return false }
        if passcode == keychainPass {
            returnVal = true
        }
        
        return returnVal
    }
    
    func passcodeControllerDidCancel(controller: CVPasscodeController) {
        if byApplication {
            exit(0)
        }
        dismiss(animated: true) {
            //
        }
    }
    
    func interfaceStringOfType(type: CVPasscodeInterfaceStringType, forPasscodeController controller: CVPasscodeController) -> String {
        switch type {
        case .Backspace:
            return "Удалить"
        case .Cancel:
            return "Отмена"
        case .InitialHint:
            return "Введите пароль"
        case .WrongHint:
            return "Пароль неверный"
        case .New:
            return "Создайте пароль"
        }
    }
    
    func passcodeDismissed() {
        deletePasscode(username: "VKPassReborn")
        needChangePasscodePrefs(true)
        let passcodeController = CVPasscodeController(interfaceStyle: .Dark, type: .new)
        passcodeController.interfaceStringProvider = self
        passcodeController.passcodeEvaluator = self
        self.present(passcodeController, animated: false, completion: nil)
    }
}

extension VKPassPrefsViewController {
    @objc func closeFunc() {
        dismiss(animated: true)
    }
    
    @objc func reloadSettings() {
        if getPasscode(username: "VKPassReborn") != nil {
            let passcodeController = CVPasscodeController(interfaceStyle: .Dark, type: .delete)
            passcodeController.interfaceStringProvider = self
            passcodeController.passcodeEvaluator = self
            passcodeController.dismissHandler = { _ in
                removePreferences()
                self.present(createVKPassAlert(cancelHandler: { _ in
                    self.viewModel.getData()
                }), animated: true)
            }
            present(passcodeController, animated: true, completion: nil)
        } else {
            removePreferences()
            self.present(createVKPassAlert(cancelHandler: { _ in
                self.viewModel.getData()
            }), animated: true)
        }
    }
}
