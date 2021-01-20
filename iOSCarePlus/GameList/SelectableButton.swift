//
//  SelectableButton.swift
//  iOSCarePlus
//
//  Created by 김지혜 on 2021/01/06.
//

import UIKit

class SelectableButton: UIButton {
//    1.
//    func select(_ value: Bool) {
//        if value {
//            setTitleColor(UIColor.init(named: "black"), for: .normal)
//        } else {
//            setTitleColor(UIColor.init(named: "VeryLightPink"), for: .normal)
//        }
//    }
    
    // 주의! 우리는 class 꺼를 쓸게 아님!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // .init 은 생략이 가능!
        setTitleColor(UIColor(named: "black"), for: .selected)
        setTitleColor(UIColor(named: "VeryLightPink"), for: .normal)
        tintColor = .clear
    }
}
