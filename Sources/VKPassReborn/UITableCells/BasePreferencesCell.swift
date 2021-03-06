//
//  BasePreferencesCell.swift
//  
//
//  Created by Alexander Orlov on 13.12.2021.
//

import UIKit

class BasePreferencesCell: UITableViewCell {
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            label.textColor = .label
        } else {
            label.textColor = .black
        }
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    var cellSwitch: UISwitch = {
        let cellSwitch = UISwitch()
        cellSwitch.translatesAutoresizingMaskIntoConstraints = false
        cellSwitch.onTintColor = .cyan
        return cellSwitch
    }()
    
    var group: Group?
    
    var model: Group.Item?
    
    private var titleConstraints: [NSLayoutConstraint] = []
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(cellSwitch)
        cellSwitch.addTarget(self, action: #selector(changeSwitch(_:)), for: .valueChanged)
        titleConstraints = [
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 15),
            titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -40)
        ]
        contentView.addConstraints(titleConstraints)
        contentView.addConstraints([
            cellSwitch.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10),
            cellSwitch.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            cellSwitch.widthAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    func setModel(_ model: Group.Item, group: Group) {
        self.group = group
        self.model = model
        titleLabel.text = model.title
        if model.type == .withSwitch {
            cellSwitch.isOn = (model.value as NSString).boolValue
        }
        if model.type == .withSwitch || model.type == .button {
            selectionStyle = .none
        } else {
            selectionStyle = .default
        }
        cellSwitch.isHidden = model.type != .withSwitch
        isUserInteractionEnabled = !model.disabled
    }
    
    private func changeType(_ type: ItemType) {
    }
    
    @objc func changeSwitch(_ value: UISwitch) {
        model?.value = String(cellSwitch.isOn)
        if let group = group,
            let model = model {
            changePreferences(group, model: [model])
        }
    }

}
