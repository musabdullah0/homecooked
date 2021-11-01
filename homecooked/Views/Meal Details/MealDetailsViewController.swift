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
    var displayMeal = Meal()

    @IBOutlet weak var imageDisplay: UIImageView!
    @IBOutlet weak var mealName: UILabel!
    @IBOutlet weak var numPortions: UILabel!
    @IBOutlet weak var portionPrice: UILabel!
    @IBOutlet weak var ingredients: UILabel!
    @IBOutlet weak var availableFrom: UIDatePicker!
    @IBOutlet weak var availableUntil: UIDatePicker!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let storage = Storage.storage()
        storageRef = storage.reference()

        // display meal image and details
        let reference = storageRef.child("\(displayMeal.meal_id).jpg")
        imageDisplay.sd_setImage(with: reference, placeholderImage: UIImage(named: "placeholderMeal.png"))
        mealName.text = displayMeal.title
        numPortions.text = String(displayMeal.portions)
        portionPrice.text = String(displayMeal.price)
        ingredients.text = displayMeal.ingredients[0]

        availableFrom.date = displayMeal.available_from
        availableUntil.date = displayMeal.available_until
    }
    
    // TODO: implement a ordering feature where the user posting a meal is notified
    // somebody is looking to purchase
    @IBAction func order(_ sender: Any) {
        
    }
    

}
