//
//  LoginViewController.swift
//  homecooked
//
//  Created by Musab Abdullah on 10/20/21.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextField.isSecureTextEntry = true

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if Auth.auth().currentUser != nil {
            print("already logged in")
            performSegue(withIdentifier: "GoHomeSegue", sender: self)
        }
    }
    
    
    @IBAction func clickedLogin(_ sender: Any) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().signIn(withEmail: email, password: password) { [weak self]  authResult, error in
                guard let strongSelf = self else { return }

                if let error = error {
                    print("error: \(error.localizedDescription)")
                } else {
                    print("login success: \(String(describing: authResult))")
                    strongSelf.performSegue(withIdentifier: "GoHomeSegue", sender: strongSelf)
                }
            }
        }
        
    }

}
