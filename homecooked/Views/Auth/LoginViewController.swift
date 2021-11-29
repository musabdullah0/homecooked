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
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextField.isSecureTextEntry = true
        errorMessageLabel.isHidden = true
        errorMessageLabel.textColor = .red
        errorMessageLabel.adjustsFontSizeToFitWidth = true
        errorMessageLabel.textAlignment = .center
    }
    
    @IBAction func clickedLogin(_ sender: Any) {
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        if (email == "" || password == "") {
            errorMessageLabel.isHidden = false
            errorMessageLabel.text = "Both email and password fields must be filled in"
        } else {
            Auth.auth().signIn(withEmail: email, password: password) { [weak self]  authResult, error in
                guard let strongSelf = self else { return }

                if let error = error {
                    // TODO: switch statements for errors
                    print("error: \(error.localizedDescription)")
                    self!.errorMessageLabel.isHidden = false
                    self!.errorMessageLabel.text = error.localizedDescription
                } else {
                    print("login success: \(String(describing: authResult))")
                    let vc = strongSelf.storyboard?.instantiateViewController(withIdentifier: "tabbar") as! UIViewController
                    vc.modalPresentationStyle = .fullScreen
                    strongSelf.present(vc, animated: true)
                }
            }
        }
    }
}
