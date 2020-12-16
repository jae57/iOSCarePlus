//
//  ViewController.swift
//  iOSCarePlus
//
//  Created by 김지혜 on 2020/12/09.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet private weak var logoView: UIView!
    @IBOutlet private weak var logoViewTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var backgroundImageLeadingConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logoView.layer.cornerRadius = 15
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        animationSettingDefault()
        
        appearLogoViewAnimation {
            [weak self] in
            // change one more view 라는 설명 쓰여진 메서드
            self?.slideBackgroundImageAnimation()
            self?.blinkLogoAnimation()
        }
    }
    
    private func animationSettingDefault() {
        logoViewTopConstraint.constant = -200
        backgroundImageLeadingConstraint.constant = 0
        logoView.alpha = 1
        view.layoutIfNeeded()
    }
    
    private func appearLogoViewAnimation(completion: @escaping () -> Void) {
        UIView.animate(
            withDuration: 0.7,
            delay: 1,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 1, // 팅구기 시작할 때의 가속도
            options: []) { [weak self] in
            self?.logoViewTopConstraint.constant = 17
            self?.view.layoutIfNeeded()
            // 지금 당장 화면을 갱신하라는 명령.
            // 일정한 주기로 적용되는걸 깨고 바로 해달라 바뀌면서 애니메이션효과를 넣어야하기 때문
        } completion: { _ in
            completion()
        }
    }
    
    private func slideBackgroundImageAnimation() {
        UIView.animate(
            withDuration: 5,
            delay: 0,
            options: [.curveEaseInOut, .repeat, .autoreverse]) { [weak self] in
                self?.backgroundImageLeadingConstraint.constant = -800
                self?.view.layoutIfNeeded()
            }
    }
    
    private func blinkLogoAnimation() {
        UIView.animate(withDuration: 1, delay: 0, options: [.repeat, .autoreverse]) { [weak self] in
            self?.logoView.alpha = 0 // hidden 을 주면 안됨. 변하는 상수값을 줘야함
        }
    }
}

