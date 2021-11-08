//
//  RegistrationController.swift
//  Auctix
//
//  Created by mac on 04.11.2021.
//

import UIKit
import Firebase

class RegistrationController: UIViewController {
    
    //MARK: Properties
    
    private let iconImage = UIImageView(image: UIImage(named: "Image3"))
    private let auctixLabel = UILabel()
    private let singUpLabel = UILabel()
    
    private let numberTextField: CustomTextField = {
    let tf = CustomTextField(placeholder: "Phone")
        tf.returnKeyType = .done
        tf.textContentType = .telephoneNumber
        return tf
    }()
    
    private let cityTextField: CustomTextField = {
    let tf = CustomTextField(placeholder: "City")
        tf.returnKeyType = .done
        tf.textContentType = .addressCity
        return tf
    }()
    
    private let fullnameTextField: CustomTextField = {
    let tf = CustomTextField(placeholder: "Fullname")
        tf.returnKeyType = .done
        tf.textContentType = .name
        return tf
    }()
    
    private let emailTextField: CustomTextField = {
        let tf = CustomTextField(placeholder: "email")
        tf.returnKeyType = .done
        tf.keyboardType = .emailAddress
        tf.textContentType = .emailAddress
        return tf
    }()
    private let passwordTextFiel: CustomTextField = {
        let tf = CustomTextField(placeholder: "Password")
        tf.returnKeyType = .done
        tf.textContentType = .password
        tf.isSecureTextEntry = true
        return tf
    }()

    private let signUpButton: AuthButton = {
        let button = AuthButton(type: .system)
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.title = "Sign Up"
        return button
    }()
    
    private let logInButton: UIButton = {
        let button = UIButton(type: .system)
        
        let atts: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.blueGreen, .font: UIFont.boldSystemFont(ofSize: 16)]
        
        let attriburedTitle = NSMutableAttributedString(string: "Log In ",
                                                        attributes: atts)
        
        button.setAttributedTitle(attriburedTitle, for: .normal)
        
        button.addTarget(self, action: #selector(showLoginController), for: .touchUpInside)
        
        return button
    }()
    
    private let custumAlert = CustomAlert()
    
    private var authUser : User? {
        return Auth.auth().currentUser
    }
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupDelegate()
    }
    
    func setupDelegate(){
        cityTextField.delegate = self
        fullnameTextField.delegate = self
        passwordTextFiel.delegate = self
        numberTextField.delegate = self
        emailTextField.delegate = self
    }
    //MARK: Selectors

    @objc func handleSignUp() {
        let name = fullnameTextField.text!
        let email = emailTextField.text!
        let password = passwordTextFiel.text!
        let number = numberTextField.text!
        let city = cityTextField.text!
        if (!name.isEmpty && !email.isEmpty && !password.isEmpty && !number.isEmpty && !city.isEmpty) {
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if error != nil{
                self.custumAlert.showAlert(title: "Error", message: "This mail is already registered", viewController: self)
            } else {
                let db = Firestore.firestore()
                db.collection("users").addDocument(data: [
                    "name": name,
                    "password": password,
                    "email": email,
                    "phone": number,
                    "city": city,
                    "uid": result!.user.uid
                ]){ (error) in
                    if error != nil {
                        print("loh")
                    } else {
                        self.sendVerificationMail()
                        self.navigationController?.popToRootViewController(animated: false)
                    }
                }
            }
        }
        } else {
            self.custumAlert.showAlert(title: "Error", message: "Not all fields were entered correctly", viewController: self)
        }
    }
    
    @objc func showLoginController() {
            //back action controller
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: Helpers
    
    func configureUI() {
        view.backgroundColor = .white

        view.addSubview(iconImage)
        iconImage.centerX(inView: view)
        iconImage.setDimensions(height: 120, width: 120)
        iconImage.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        
        view.addSubview(auctixLabel)
        auctixLabel.text = "Auctix"
        auctixLabel.textColor = UIColor.blueGreen
        auctixLabel.centerX(inView: view)
        auctixLabel.anchor(top: iconImage.bottomAnchor, paddingTop: 20)
        
        view.addSubview(logInButton)
        view.addSubview(singUpLabel)
        
        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
        let underlineAttributedString = NSAttributedString(string: "StringWithUnderLine", attributes: underlineAttribute)
        singUpLabel.attributedText = underlineAttributedString
        singUpLabel.text = "Sign Up"
        singUpLabel.font = UIFont.boldSystemFont(ofSize: 16)
        singUpLabel.textColor = UIColor.blueGreen
        
        logInButton.anchor(top: auctixLabel.bottomAnchor, left: view.leftAnchor, paddingTop: 32, paddingLeft: 32)
        singUpLabel.anchor(top: auctixLabel.bottomAnchor, right: view.rightAnchor, paddingTop: 32, paddingRight: 32)
        
        
        let stack = UIStackView(arrangedSubviews: [emailTextField,
                                                   passwordTextFiel,
                                                   fullnameTextField,
                                                   cityTextField,
                                                   numberTextField,
                                                   signUpButton])
        stack.axis = .vertical
        stack.spacing = 20
        
        view.addSubview(stack)
        stack.anchor(top: logInButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 16, paddingLeft: 32, paddingRight: 32)
    }
    
    public func sendVerificationMail() {
        if self.authUser != nil && !self.authUser!.isEmailVerified {
            self.authUser!.sendEmailVerification(completion: { (error) in
                //Сообщите пользователю, что письмо отправлено или не может быть отправлено из-за ошибки.
                if error != nil {
                    
                } else {
                    //self.custumAlert.showAlert(title: "Super", message: "Your account has been created! We sent you an email, do not forget to confirm it", viewController: self)
                }
            })
        }
        else {
            //Либо пользователь недоступен, либо пользователь уже верифицирован.
        }
    }
}

extension RegistrationController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        cityTextField.resignFirstResponder()
        fullnameTextField.resignFirstResponder()
        passwordTextFiel.resignFirstResponder()
        numberTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        return true
    }
}
