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
    
    var activeTextField : UITextField? = nil
    
    private let iconImage = UIImageView(image: UIImage(named: "Image3"))
    private let auctixLabel = UILabel()
    private let singUpLabel = UILabel()
    
    private let numberTextField: CustomTextField = {
    let tf = CustomTextField(placeholder: "Phone")
        tf.returnKeyType = .done
        tf.textContentType = .telephoneNumber
        tf.keyboardType = .numberPad
        tf.keyboardAppearance = .light
        tf.addDoneCanselToolBar()
        
        return tf
    }()
    
    private let cityTextField: CustomTextField = {
    let tf = CustomTextField(placeholder: "City")
        tf.returnKeyType = .done
        tf.textContentType = .addressCity
        tf.keyboardAppearance = .light
        return tf
    }()
    
    private let fullnameTextField: CustomTextField = {
    let tf = CustomTextField(placeholder: "Fullname")
        tf.returnKeyType = .done
        tf.textContentType = .name
        tf.keyboardAppearance = .light
        return tf
    }()
    
    private let emailTextField: CustomTextField = {
        let tf = CustomTextField(placeholder: "email")
        tf.returnKeyType = .done
        tf.keyboardType = .emailAddress
        tf.textContentType = .emailAddress
        tf.keyboardAppearance = .light
        return tf
    }()
    private let passwordTextFiel: CustomTextField = {
        let tf = CustomTextField(placeholder: "Password")
        tf.returnKeyType = .done
        tf.textContentType = .password
        tf.isSecureTextEntry = true
        tf.keyboardAppearance = .light
        return tf
    }()

    private let signUpButton: AuthButton = {
        let button = AuthButton(type: .system)
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.title = "Sign Up"
        return button
    }()
    
    private let leterButton: AuthButton = {
        let button = AuthButton(type: .system)
        button.addTarget(self, action: #selector(handleLeter), for: .touchUpInside)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.title = "Register later"
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
    
//    private var authUser : User? {
//        return Auth.auth().currentUser
//    }
    
    //для форматирования строки телефона
    private let maxNumberCount = 11
    private let regex = try! NSRegularExpression(pattern: "[\\+\\s-\\(\\)]", options: .caseInsensitive)
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerForKeyboardNotifications()
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

    @objc func handleLeter() {
        let tabBarVC = TabBarViewController()
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else { return }
        sceneDelegate.window?.rootViewController = tabBarVC
        UserDefaults.standard.set(true, forKey: "isFirstStart")
    }
    
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
                    //"password": password,
                    "email": email,
                    "phone": number,
                    "city": city,
                    "id": result!.user.uid
                ]){ (error) in
                    if error != nil {
                        print("loh")
                    } else {
                        self.sendVerificationMail()
                        let controller = self.navigationController?.parent
                        if controller?.superclass?.description() == Optional<String>.some("UITabBarController") {
                            self.navigationController?.popToRootViewController(animated: false)
                        } else {
                            let tabBarVC = TabBarViewController()
                            guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else { return }
                            sceneDelegate.window?.rootViewController = tabBarVC
                        }
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
        auctixLabel.attributedText = getAttrTitle()
        auctixLabel.centerX(inView: view)
        auctixLabel.anchor(top: iconImage.bottomAnchor, paddingTop: 20)
        
        let controller = self.navigationController?.parent
        
        if controller?.superclass?.description() == Optional<String>.some("UITabBarController") {
        
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
        
        }
        
        let stack = UIStackView(arrangedSubviews: [emailTextField,
                                                   passwordTextFiel,
                                                   fullnameTextField,
                                                   cityTextField,
                                                   numberTextField,
                                                   signUpButton])
        stack.axis = .vertical
        stack.spacing = 20
        
        view.addSubview(stack)
        if controller?.superclass?.description() == Optional<String>.some("UITabBarController") {
            stack.anchor(top: logInButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 16, paddingLeft: 32, paddingRight: 32)
        } else {
            stack.anchor(top: auctixLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 16, paddingLeft: 32, paddingRight: 32)
            view.addSubview(leterButton)
            leterButton.anchor(top: stack.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 16, paddingLeft: 32, paddingRight: 32)
        }
        
        
    }
    
    public func sendVerificationMail() {
        if Auth.auth().currentUser != nil && !Auth.auth().currentUser!.isEmailVerified {
            Auth.auth().currentUser!.sendEmailVerification(completion: { (error) in
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
    
    //для форматирования строки телефона
    private func format(phoneNumber: String, shouldRemoveLastDigit: Bool) -> String {
        guard !(shouldRemoveLastDigit && phoneNumber.count <= 2) else { return "+" }
               
        let range = NSString(string: phoneNumber).range(of: phoneNumber)
        var number = regex.stringByReplacingMatches(in: phoneNumber, options: [], range: range, withTemplate: "")
        
        if number.count > maxNumberCount {
            let maxIndex = number.index(number.startIndex, offsetBy: maxNumberCount)
            number = String(number[number.startIndex..<maxIndex])
        }
        
        if shouldRemoveLastDigit {
            let maxIndex = number.index(number.startIndex, offsetBy: number.count - 1)
            number = String(number[number.startIndex..<maxIndex])
        }
            
        let maxIndex = number.index(number.startIndex, offsetBy: number.count)
        let regRange = number.startIndex..<maxIndex
        
        if number.count < 7 {
            let pattern = "(\\d)(\\d{3})(\\d+)"
            number = number.replacingOccurrences(of: pattern, with: "$1 ($2) $3", options: .regularExpression, range: regRange)
        } else {
            let pattern = "(\\d)(\\d{3})(\\d{3})(\\d{2})(\\d+)"
            number = number.replacingOccurrences(of: pattern, with: "$1 ($2) $3-$4-$5", options: .regularExpression, range: regRange)
        }
        
        if number.count == 1 {
            return "+" + "7"
        } else {
            return "+" + number
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == numberTextField {
            let fullString = (textField.text ?? "") + string
            textField.text = format(phoneNumber: fullString, shouldRemoveLastDigit: range.length == 1)
            return false
        } else {
        return true
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeTextField = textField
    }
}
//расширение текстфилда для добавление тулбара на циферную клавиатуру
extension UITextField {
    func addDoneCanselToolBar(onDone: (target: Any, action: Selector)? = nil, onCancle: (target: Any, action: Selector)? = nil) {
        let onDone = onDone ?? (target: self, action: #selector(doneButtonTapped))
        let onCancle = onCancle ?? (target: self, action: #selector(canselButtonTapped))
        
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.items = [
            UIBarButtonItem(title: "Cancel", style: .plain, target: onCancle.target, action: onCancle.action),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Done", style: .plain, target: onDone.target, action: onDone.action)
        ]
        toolBar.sizeToFit()
        self.inputAccessoryView = toolBar
    }
    
    @objc
    func doneButtonTapped() {
        self.resignFirstResponder()
    }
    @objc
    func canselButtonTapped() {
        self.resignFirstResponder()
    }
}

extension RegistrationController {
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(RegistrationController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RegistrationController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc
    func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            // if keyboard size is not available for some reason, dont do anything
           return
        }
        
        var shouldMoveViewUpCity = false
        var scholdMoveViewUpNum = false
        
        // if active text field is not nil
        if let activeTextField = activeTextField {
            let bottomOfTextField = activeTextField.convert(activeTextField.bounds, to: self.view).maxY;
            let topOfKeyboard = self.view.frame.height - keyboardSize.height
            
            if activeTextField == cityTextField {
                if bottomOfTextField > topOfKeyboard {
                    shouldMoveViewUpCity = true
                }
            }
            if activeTextField == numberTextField {
                if bottomOfTextField > topOfKeyboard {
                    scholdMoveViewUpNum = true
                }
            }
        }
        
        if(shouldMoveViewUpCity) {
            self.view.frame.origin.y = 0 - keyboardSize.height/8
        }
        if(scholdMoveViewUpNum) {
            self.view.frame.origin.y = 0 - keyboardSize.height/3
        }

    }
    
    @objc
    func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
}

