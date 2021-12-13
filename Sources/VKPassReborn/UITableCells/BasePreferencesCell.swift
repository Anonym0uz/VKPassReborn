//
//  BasePreferencesCell.swift
//  
//
//  Created by Alexander Orlov on 13.12.2021.
//

import UIKit

class BasePreferencesCell: UITableViewCell {
    
    var cellSwitch: UISwitch = {
        let cellSwitch = UISwitch()
        cellSwitch.translatesAutoresizingMaskIntoConstraints = false
        cellSwitch.onTintColor = .orange
        return cellSwitch
    }()
    var model: Group.Item?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        contentView.addSubview(cellSwitch)
        contentView.addConstraints([
            cellSwitch.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10),
            cellSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            cellSwitch.heightAnchor.constraint(equalToConstant: 40),
            cellSwitch.widthAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    func setModel(_ model: Group.Item) {
        self.model = model
        self.textLabel?.text = model.key
        cellSwitch.isHidden = model.type != .withSwitch
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
