//
//  LoginInViewController.swift
//  CloudCamera
//
//  Created by Cristian Molina on 10/10/18.
//  Copyright © 2018 Cristian Molina. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class LoginInViewController: UIViewController {
    var email: String?
    
    
    var ref: DatabaseReference!
    var handle: AuthStateDidChangeListenerHandle?
    
    
    
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var userNameTextField: UITextField!
    
    @IBOutlet weak var passWordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton! {
        didSet {
            loginButton.layer.borderWidth = 2
            loginButton.layer.borderColor = UIColor.white.cgColor
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textFiledsBordering()
//        ref = Database.database().reference()
        

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                self.userNameTextField.text = user.email
                print(user.uid)
                self.performSegue(withIdentifier: "initialscreen", sender: self)
            } else {
                self.passWordTextField.text = ""
            }
    
    }
        
    
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        
        
        do {
            try login()
        } catch LoginError.incompleteForm {
//            print("Passwrod or Username textfield is empty")
            
            errorLabel.text = "Password or Username is empty."
        } catch LoginError.invalidEmail {
//            print("Invalid Email")
            errorLabel.text = "Invalid e-mail format."
        } catch LoginError.incorrectPasswordLenght {
//            print("Password not long enough")
            errorLabel.text = "Password must be 8 characters long"
        } catch {
//            print("Something went wrong")
            errorLabel.text = "Something went wrong"
        }
    }
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        
    }
    
    
    private func textFiledsBordering()
    {
        let userNameBorder = CALayer()
        let width = CGFloat(2.0)
        userNameBorder.borderColor = UIColor.white.cgColor
        userNameBorder.frame = CGRect(x: 0, y: userNameTextField.frame.size.height - width, width: userNameTextField.frame.size.width, height: userNameTextField.frame.size.height)
        userNameBorder.borderWidth = width
        
        
        let passwordBorder = CALayer()
//        let width = CGFloat(2.0)
        passwordBorder.borderColor = UIColor.white.cgColor
        passwordBorder.frame = CGRect(x: 0, y: passWordTextField.frame.size.height - width, width: passWordTextField.frame.size.width, height: passWordTextField.frame.size.height)
        passwordBorder.borderWidth = width
        
        
        
        userNameTextField.layer.addSublayer(userNameBorder)
        userNameTextField.layer.masksToBounds = true
        passWordTextField.layer.addSublayer(passwordBorder)
        passWordTextField.layer.masksToBounds = true
        
        userNameTextField.delegate = self
        passWordTextField.delegate = self
        
    }
    
    
    
    
    enum LoginError: Error {
        case incompleteForm
        case invalidEmail
        case incorrectPasswordLenght
    }
    
    
    
    
    private func login() throws
    {
        
        let email = userNameTextField.text!
        let password = passWordTextField.text!
        
        if email.isEmpty || password.isEmpty {
            throw LoginError.incompleteForm
        }
        if !email.isValidEmail {
            throw LoginError.invalidEmail
        }
        
        if password.count < 8 {
            throw LoginError.incorrectPasswordLenght
        }
        errorLabel.text = ""
        
        print("Login")

        
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if user != nil && error == nil {
                print("Successfully logged in user")
                
                
                
                
            } else {
                self.errorLabel.text = "Somethign went wrong"
            }
            
        }
        
        
        
    }

    @IBAction func signUpTapped(_ sender: UIButton) {
        
        self.performSegue(withIdentifier: "signup", sender: self)
    }
    
}
extension String {
    var isValidEmail : Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: self)
    }
}


extension LoginInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
}
