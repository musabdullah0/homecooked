//
//  PostMealViewController.swift
//  homecooked
//
//  Created by Max Rattray on 10/20/21.
//
import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseStorageUI
import UIKit

class PostMealViewController: UIViewController {

    @IBOutlet weak var imageDisplay: UIImageView!
    @IBOutlet weak var mealName: UITextField!
    @IBOutlet weak var numPortions: UITextField!
    @IBOutlet weak var portionPrice: UITextField!
    @IBOutlet weak var ingredients: UITextField!
    @IBOutlet weak var nutrientInfo: UITextField!
    @IBOutlet weak var dateSelect: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //1 doc per meal
        // Do any additional setup after loading the view.
    }
    
    @IBAction func imageSelect(_ sender: Any) {
    }
    
    
    @IBAction func postMeal(_ sender: Any) {
        //date todo
        let uuid = UUID().uuidString
        Firestore.firestore().collection("meals").document(uuid).setData([
            "mealName": mealName.text!,
            "numPortions": numPortions.text!,
            "portionPrice": portionPrice.text!,
            "ingredients": ingredients.text!,
            "nutrientInfo": nutrientInfo.text!
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
        
        self.dismiss(animated:false, completion: nil)
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
