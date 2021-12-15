//
//  TestViewController.swift
//  
//
//  Created by Alexander Orlov on 13.12.2021.
//

import UIKit
import Foundation

final class TestViewController: UIViewController {
    
    let centeredLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .red
        label.text = "This is centered label!"
        label.backgroundColor = .white
        return label
    }()
    
    let testButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .red
        button.setTitle("Test create", for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationController(navigationController,
                                  item: navigationItem)
        view.backgroundColor = .green
        view.addSubview(centeredLabel)
        view.addSubview(testButton)
        testButton.addTarget(self, action: #selector(createPrefs), for: .touchUpInside)
        let closeButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeFunc))
        navigationItem.leftBarButtonItems = [closeButton]
        view.addConstraints([
            centeredLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centeredLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            testButton.topAnchor.constraint(equalTo: centeredLabel.bottomAnchor, constant: 10),
            testButton.centerXAnchor.constraint(equalTo: centeredLabel.centerXAnchor),
            testButton.heightAnchor.constraint(equalToConstant: 50),
            testButton.widthAnchor.constraint(equalToConstant: 120)
        ])
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let alert = UIAlertController(title: "Test", message: "\(getPath()) - \(getDocumentsDictionary())", preferredStyle: .actionSheet)
            alert.addAction(.init(title: "OK", style: .cancel))
            self.present(alert, animated: true)
        }
    }
    
    @objc func closeFunc() {
        dismiss(animated: true)
    }
    
    @objc func createPrefs() {
        navigationController?.pushViewController(VKPassPrefsViewController(viewModel: .init()), animated: true)
    }
}
