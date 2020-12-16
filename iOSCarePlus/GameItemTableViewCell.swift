//
//  GameItemTableViewCell.swift
//  iOSCarePlus
//
//  Created by 김지혜 on 2020/12/16.
//

import Kingfisher
import UIKit

class GameItemTableViewCell: UITableViewCell {
    private var model: GameItemModel? {
        didSet {
            updateUIFromModel()
        }
    }
    @IBOutlet private weak var gameImageView: UIImageView!
    @IBOutlet private weak var gameTitleLabel: UILabel!
    @IBOutlet private weak var gamePriceLabel: UILabel!
    @IBOutlet private weak var gameSalePriceLabel: UILabel!
        
    func setModel(_ model: GameItemModel) {
        self.model = model
    }
    
    func updateUIFromModel() {
        guard let model = model else { return }
        
        let imageUrl: URL? = URL(string: model.imageUrl)
        gameImageView.kf.setImage(with: imageUrl)
        
        gameImageView.layer.cornerRadius = 9
        gameImageView.layer.borderWidth = 1
        gameImageView.layer.borderColor = UIColor(red: 236 / 255.0, green: 236 / 255.0, blue: 236 / 255.0, alpha: 1).cgColor
        
        gameTitleLabel.text = model.gameTitle
        if let price: Int = model.gamePrice {
            gamePriceLabel.text = "₩\(price.withCommas())"
        } else {
            gamePriceLabel.isHidden = true
        }
        gameSalePriceLabel.text = "₩\(model.gameSalePrice.withCommas())"
    }
}

extension Int {
    func withCommas() -> String {
        let numberFormatter: NumberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value: self))!
    }
}
