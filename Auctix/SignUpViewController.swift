//
//  SignUpViewController.swift
//  Auctix
//
//  Created by Евгений Башун on 21.10.2021.
//

import UIKit
import SnapKit

class SignUpViewController: UIViewController {

    private let label = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .yellow
        setupLabel()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setupLayout()
    }

    private func setupLabel() {
        label.text = "Hi"
        view.addSubview(label)
    }
   
    private func setupLayout(){
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

}
