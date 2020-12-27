//
//  GameItemCodeTableViewCell.swift
//  iOSCarePlus
//
//  Created by 김지혜 on 2020/12/23.
//

import UIKit

class GameItemCodeTableViewCell: UITableViewCell {
    var gameImageView: UIImageView
    var titleLabel: UILabel
    var priceLabel: UILabel
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        gameImageView = UIImageView()
        titleLabel = UILabel()
        priceLabel = UILabel()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        gameImageView.backgroundColor = .blue
        titleLabel.text = "test"
        
        contentView.addSubview(gameImageView) // cell 은 무조건 content view 에 view 추가해야함
        contentView.addSubview(titleLabel)
        contentView.addSubview(priceLabel)
        
        gameImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            gameImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            gameImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            gameImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            gameImageView.heightAnchor.constraint(equalToConstant: 69),
            gameImageView.widthAnchor.constraint(equalToConstant: 122)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: gameImageView.topAnchor, constant: 5),
            titleLabel.leadingAnchor.constraint(equalTo: gameImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(greaterThanOrEqualTo: contentView.trailingAnchor, constant: 15)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
