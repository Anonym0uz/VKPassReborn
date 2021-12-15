//
//  VKPassPrefsViewController.swift
//  
//
//  Created by Alexander Orlov on 13.12.2021.
//

import UIKit

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
        let closeButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeFunc))
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
            return groups[section].items.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let groups = groups {
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
            let alert = UIAlertController(title: "Test", message: groups[indexPath.section].items[indexPath.row].key, preferredStyle: .alert)
            alert.addAction(.init(title: "OK", style: .cancel))
            self.present(alert, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
}

extension VKPassPrefsViewController {
    @objc func closeFunc() {
        dismiss(animated: true)
    }
    
    @objc func reloadSettings() {
        removePreferences()
        tableView.reloadData()
    }
}
