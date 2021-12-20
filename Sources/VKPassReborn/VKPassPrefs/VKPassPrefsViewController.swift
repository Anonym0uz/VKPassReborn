//
//  VKPassPrefsViewController.swift
//  
//
//  Created by Alexander Orlov on 13.12.2021.
//

import UIKit
import Security

struct Credentials {
    var username: String
    var password: String
}
enum KeychainError: Error {
    case noPassword
    case unexpectedPasswordData
    case unhandledError(status: OSStatus)
}

func deletePassword(account: String) throws {
    let query: [String: AnyObject] = [
        kSecAttrAccount as String: account as AnyObject,
        kSecClass as String: kSecClassGenericPassword
    ]
    
    let status = SecItemDelete(query as CFDictionary)
    
    guard status == errSecSuccess else {
        throw KeychainError.unhandledError(status: status)
    }
}

private func storeKeychain(username: String, password: String) throws -> Any? {
    let credentials = Credentials.init(username: username, password: password)
    let data = credentials.password.data(using: .utf8)!

    let query: [String: Any] = [kSecClass as String:  kSecClassGenericPassword,
                                kSecAttrAccount as String: username,
                                kSecValueData as String: data]
    let status = SecItemAdd(query as CFDictionary, nil)
    guard status == errSecSuccess else {
        throw KeychainError.unhandledError(status: status) }
    return status
}

private func getKeychain() throws -> String {
    let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                kSecMatchLimit as String: kSecMatchLimitOne,
                                kSecReturnAttributes as String: true,
                                kSecReturnData as String: true]
    var item: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &item)
    guard status != errSecItemNotFound else { throw KeychainError.noPassword }
    guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
    
    guard let existingItem = item as? [String : Any],
          let passwordData = existingItem[kSecValueData as String] as? Data,
          let password = String(data: passwordData, encoding: String.Encoding.utf8),
          let account = existingItem[kSecAttrAccount as String] as? String
    else {
        throw KeychainError.unexpectedPasswordData
    }
    _ = Credentials(username: account, password: password)
    return password
}

class VKPassPrefsViewController: UIViewController {
    
    var viewModel: VKPassPrefsViewModelProtocol
    var tableView: UITableView!
    var groups: [Group]?
    
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
            self.groups = self.viewModel.items
            self.tableView.reloadData()
        }
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
            return groups[section].items.filter({ $0.isHidden == false }).count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let sectionImage = UIImageView()
            sectionImage.contentMode = .scaleAspectFill
            sectionImage.image = UIImage(named: "\(tweakResourceFolder)/vkpassheader.jpg")
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
//                let alert = UIAlertController(title: "Test", message: groups[indexPath.section].items[indexPath.row].key, preferredStyle: .alert)
//                alert.addAction(.init(title: "OK", style: .cancel))
//                self.present(alert, animated: true)
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
            print("passcode setup")
//            _ = try? storeKeychain(username: "VKPassReborn", password: passcode)
//            let password = try? getKeychain()
//            needChangePasscodePrefs(false)
//            print(password)
        case .check:
            print("passcode check")
        case .change:
            print("passcode change")
        case .delete:
            print("passcode delete")
        }
    }
    
    func evaluatePasscode(passcode: String, forPasscodeController controller: CVPasscodeController) -> Bool {
        var returnVal = false
        guard let keychainPass = try? getKeychain() else { return false }
        if passcode == keychainPass {
            returnVal = true
        }
        
        return returnVal
    }
    
    func passcodeControllerDidCancel(controller: CVPasscodeController) {
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
    
    
}

extension VKPassPrefsViewController {
    @objc func closeFunc() {
        dismiss(animated: true)
    }
    
    @objc func reloadSettings() {
        removePreferences()
        let alert = UIAlertController(title: "VKPassReborn", message: "Preferences has been reloaded.", preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .cancel, handler: { _ in
            self.viewModel.getData()
        }))
        present(alert, animated: true)
    }
}
