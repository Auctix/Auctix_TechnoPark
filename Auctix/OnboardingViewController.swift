//
//  OnboardingViewController.swift
//  Auctix
//
//  Created by Евгений Башун on 21.10.2021.
//

import UIKit
import SnapKit

class OnboardingViewController: UIViewController {

    let label = UILabel()
    let extralabel = UILabel()
    let buttonContinue = UIButton()
    let buttonSignUp = UIButton()
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }

    private func initialize() {
        view.backgroundColor = UIColor.blueGreen
        setupButtons()
        setupLabels()
    }
    
    
    func setupButtons() {
        
        buttonContinue.setTitle("Register later", for: .normal)
        buttonContinue.titleLabel?.numberOfLines = 0
        buttonContinue.titleLabel?.font = UIFont(name: "Nunito-Regular", size: 14)
        view.addSubview(buttonContinue)
        buttonContinue.snp.makeConstraints { maker in
            maker.bottom.equalToSuperview().inset(UIScreen.main.bounds.height/20)
            maker.leading.trailing.equalToSuperview().inset(50)
        }
        
        buttonContinue.addTarget(self, action: #selector(buttonContinueTapped), for: .touchUpInside)

        buttonSignUp.backgroundColor = UIColor.honeyYellow
        buttonSignUp.setTitle("Sign Up", for: .normal)
        buttonSignUp.titleLabel?.font = UIFont(name: "Nunito-Regular", size: 20)
        buttonSignUp.titleLabel?.adjustsFontSizeToFitWidth = true
        buttonSignUp.layer.cornerRadius = 20
        view.addSubview(buttonSignUp)
        buttonSignUp.snp.makeConstraints { maker in
            maker.centerX.equalToSuperview()
            maker.bottom.equalTo(buttonContinue).inset(30)
            maker.height.equalTo(40)
            maker.width.equalTo(150)
        }
        
        buttonSignUp.addTarget(self, action: #selector(buttonSignUpTapped), for: .touchUpInside)
        
    }
    
    func setupLabels() {
        
        label.text = "🎉 Welcome! 🎉"
        label.font = UIFont(name: "Nunito-Black", size: 26)
        label.adjustsFontSizeToFitWidth = true
        view.addSubview(label)
        label.textColor = .white
        label.snp.makeConstraints { maker in
            maker.centerX.equalToSuperview()
            maker.top.equalToSuperview().inset(UIScreen.main.bounds.height/10)
        }
        
        extralabel.text = "We are happy to welcome you! Using our application, you can buy rare paintings that are shown at exhibitions. Register in the app to bid on the paintings you like."
        extralabel.font = UIFont(name: "Nunito-Regular", size: 24)
        extralabel.numberOfLines = 0
        extralabel.textColor = .white
        extralabel.adjustsFontSizeToFitWidth = true
        view.addSubview(extralabel)
        extralabel.snp.makeConstraints { maker in
            maker.leading.trailing.equalToSuperview().inset(50)
            maker.top.equalTo(label).inset(70)
            maker.bottom.lessThanOrEqualTo(buttonSignUp).inset(70)
            
        }
    }
    
    
    @objc private func buttonSignUpTapped() {
        let signUpVC = SignUpViewController()
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else { return }
        sceneDelegate.window?.rootViewController = signUpVC
        UserDefaults.standard.set(true, forKey: "isFirstStart")
    }

    @objc private func buttonContinueTapped() {
        let tabBarVC = TabBarViewController()
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else { return }
        sceneDelegate.window?.rootViewController = tabBarVC
        UserDefaults.standard.set(true, forKey: "isFirstStart")
    }
}
