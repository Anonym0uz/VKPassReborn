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
        label.textColor = .white
        label.textAlignment = .left
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
        contentView.addConstraints([
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 15),
            titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -40),
            
            cellSwitch.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10),
            cellSwitch.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            cellSwitch.widthAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    func setModel(_ model: Group.Item, group: Group) {
        self.group = group
        self.model = model
        titleLabel.text = model.key
        if model.type == .withSwitch {
            cellSwitch.isOn = (model.value as NSString).boolValue
        }
        selectionStyle = model.type != .withSwitch ? .default : .none
        isUserInteractionEnabled = model.type != .withSwitch
        cellSwitch.isHidden = model.type != .withSwitch
    }
    
    @objc func changeSwitch(_ value: UISwitch) {
        model?.value = String(cellSwitch.isOn)
        if let group = group,
            let model = model {
            changePreferences(group, model: model)
        }
    }

}
