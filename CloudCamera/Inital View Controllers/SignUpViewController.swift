//
//  SignUpViewController.swift
//  CloudCamera
//
//  Created by Cristian Molina on 10/11/18.
//  Copyright © 2018 Cristian Molina. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class SignUpViewController: UIViewController {
    var ref: DatabaseReference!

    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var signUpButton: UIButton! {
        didSet {
            signUpButton.layer.borderWidth = 2
            signUpButton.layer.borderColor = UIColor.white.cgColor
        }
    }
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        setUpTextFieldBorders()
        // Do any additional setup after loading the view.
    }
    

    private func setUpTextFieldBorders() {
        let passwordBorder = CALayer()
        let width = CGFloat(2.0)
        passwordBorder.borderColor = UIColor.white.cgColor
        passwordBorder.frame = CGRect(x: 0, y: passwordTextField.frame.size.height - width, width: passwordTextField.frame.size.width, height: passwordTextField.frame.size.height)
        passwordBorder.borderWidth = width
        passwordTextField.layer.addSublayer(passwordBorder)
        passwordTextField.layer.masksToBounds = true
        
        let usernameBorder = CALayer()
//        let width = CGFloat(2.0)
        usernameBorder.borderColor = UIColor.white.cgColor
        usernameBorder.frame = CGRect(x: 0, y: usernameTextField.frame.size.height - width, width: usernameTextField.frame.size.width, height: usernameTextField.frame.size.height)
        usernameBorder.borderWidth = width
        usernameTextField.layer.addSublayer(usernameBorder)
        usernameTextField.layer.masksToBounds = true
        
        let emailBorder = CALayer()
//        let width = CGFloat(2.0)
        emailBorder.borderColor = UIColor.white.cgColor
        emailBorder.frame = CGRect(x: 0, y: emailTextField.frame.size.height - width, width: emailTextField.frame.size.width, height: emailTextField.frame.size.height)
        emailBorder.borderWidth = width
        emailTextField.layer.addSublayer(emailBorder)
        emailTextField.layer.masksToBounds = true
        
        
        
        emailTextField.delegate = self
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    
    @IBAction func signUpTapped(_ sender: UIButton) {
    
        do {
            try signUp()
        } catch SignUpError.incompleteForm {
            errorLabel.text = "Something is empty"
            
        } catch SignUpError.invalidEmail {
            errorLabel.text = "Invaid e-mail format"
            
        } catch SignUpError.incorrectPasswordLenght {
            errorLabel.text = "Password must be 8 characters long"
            
        } catch {
            errorLabel.text = "Something went wrong"
        }
    }
    
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    enum SignUpError: Error {
        case incompleteForm
        case invalidEmail
        case incorrectPasswordLenght
    }
    
    
    
    private func signUp() throws
    {
        let email = emailTextField.text!
        let password = passwordTextField.text!
        let username = usernameTextField.text!
        
        if email.isEmpty || password.isEmpty || username.isEmpty{
            throw SignUpError.incompleteForm
            
        }
        if !email.isValidEmail {
            throw SignUpError.invalidEmail
        }
        
        if password.count < 8 {
            throw SignUpError.incorrectPasswordLenght
        }
        
        errorLabel.text = ""
 
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            if error != nil {
                print(error?.localizedDescription ?? "ERROR: with creating user")
            } else {
                if let user = authResult?.user {

                    let userValue = ["username": username, "email": user.email]
                    self.ref.child("users").child(user.uid).setValue(userValue, withCompletionBlock: { (error, _) in
                        if let error = error {
                            print(error.localizedDescription)
                        } else {
                            print("User saved successfully!")
                        }
                    })
//                    self.ref.child("users").child(user.uid).setValue(["username": username])
                    print(user)
                } else {
                    print("ERROR: User not created")
                }
            }
        }
        
        
        
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    
}



extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
