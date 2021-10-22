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
    }
    
    @IBAction func clickedCreateAccount(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(identifier: "signup") as! SignUpViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    @IBAction func clickedLogin(_ sender: Any) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().signIn(withEmail: email, password: password) { [weak self]  authResult, error in
                guard let strongSelf = self else { return }
                if let error = error {
                    print("error: \(error.localizedDescription)")
                } else {
                    print("login success: \(String(describing: authResult))")
                    let vc = strongSelf.storyboard?.instantiateViewController(withIdentifier: "tabbar") as! UIViewController
                    vc.modalPresentationStyle = .fullScreen
                    strongSelf.present(vc, animated: true)
                }
            }
        }
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
