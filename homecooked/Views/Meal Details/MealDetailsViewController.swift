//
//  MealDetailsViewController.swift
//  homecooked
//
//  Created by Max Rattray on 10/20/21.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseStorageUI

class MealDetailsViewController: UIViewController {
    
    var storageRef: StorageReference!

    @IBOutlet weak var imageDisplay: UIImageView!
    @IBOutlet weak var mealName: UITextField!
    @IBOutlet weak var numPortions: UITextField!
    @IBOutlet weak var portionPrice: UILabel!
    @IBOutlet weak var ingredients: UILabel!
    @IBOutlet weak var nutrientInfo: UILabel!
    @IBOutlet weak var dateAvailable: UILabel!
    
    var displayMeal = Meal()
    

    override func viewDidLoad() {
        let storage = Storage.storage()
        storageRef = storage.reference()
        
        let reference = storageRef.child("\(displayMeal.meal_id).jpg")
        imageDisplay.sd_setImage(with: reference, placeholderImage: UIImage(named: "placeholderMeal.png"))
        mealName.text = displayMeal.title
        numPortions.text = String(displayMeal.remaining)
        portionPrice.text = String(displayMeal.price)
        ingredients.text = displayMeal.ingredients
        nutrientInfo.text = displayMeal.nutrientInfo
        
        // Create Date
        let date = displayMeal.dateAvailable
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YY/MM/dd"
        dateAvailable.text = dateFormatter.string(from: date)
        super.viewDidLoad()
    }
    
    @IBAction func order(_ sender: Any) {
        
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
