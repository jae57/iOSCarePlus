//
//  IndicatorTableViewCell.swift
//  iOSCarePlus
//
//  Created by 김지혜 on 2020/12/23.
//

import UIKit

class IndicatorTableViewCell: UITableViewCell {
    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
    
    func animationIndicatorView(on: Bool) {
        if on {
            activityIndicatorView.startAnimating()
        } else {
            activityIndicatorView.stopAnimating()
        }
    }
}
