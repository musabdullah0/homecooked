//
//  SignUpViewController.swift
//  homecooked
//
//  Created by Musab Abdullah on 10/20/21.
//

import UIKit
import FirebaseAuth
import Firebase

class SignUpViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    @IBAction func clickedSignup(_ sender: Any) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
                guard let strongSelf = self else { return }
                if let error = error {
                    print("sign up error: \(error.localizedDescription)")
                } else {
                    print("sign up success: \(String(describing: authResult))")
                    
                    Firestore.firestore().collection("users").document(authResult?.user.uid ?? "fakeuid").setData([
                        "name": self?.nameTextField?.text ?? "no name",
                        "email": email,
                    ]) { err in
                        if let err = err {
                            print("Error writing user: \(err)")
                        } else {
                            print("user doc succesfully written!")
                        }

                    }
                    
                    let vc = strongSelf.storyboard?.instantiateViewController(withIdentifier: "tabbar") as! UIViewController
                    vc.modalPresentationStyle = .fullScreen
                    strongSelf.present(vc, animated: true)

                }
            }
        }
    }

}
