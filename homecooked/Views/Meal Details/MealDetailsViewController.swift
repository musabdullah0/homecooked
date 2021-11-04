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
import CoreLocation

class MealDetailsViewController: UIViewController {
    
    var storageRef: StorageReference!
    var displayMeal = Meal()

    @IBOutlet weak var imageDisplay: UIImageView!
    @IBOutlet weak var mealName: UILabel!
    @IBOutlet weak var numPortions: UILabel!
    @IBOutlet weak var portionPrice: UILabel!
    @IBOutlet weak var ingredients: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var availableFrom: UIDatePicker!
    @IBOutlet weak var availableUntil: UIDatePicker!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let storage = Storage.storage()
        storageRef = storage.reference()

        let reference = storageRef.child("\(displayMeal.meal_id).jpg")
        imageDisplay.sd_setImage(with: reference, placeholderImage: UIImage(named: "placeholderMeal.png"))
        
        imageDisplay.layer.cornerRadius = imageDisplay.frame.height / 2
        imageDisplay.layer.masksToBounds = false
        imageDisplay.clipsToBounds = true
        imageDisplay.contentMode = .scaleAspectFill
        
        mealName.text = displayMeal.title
        numPortions.text = String(displayMeal.portions)
        portionPrice.text = String(displayMeal.price)
        ingredients.text = displayMeal.ingredients.joined(separator: ",")

        availableFrom.date = displayMeal.available_from
        availableUntil.date = displayMeal.available_until
        
        let clocation = CLLocation(latitude: displayMeal.location.latitude, longitude: displayMeal.location.longitude)
        
        CLGeocoder().reverseGeocodeLocation(clocation, completionHandler: {(placemarks, error) -> Void in
            if let error = error {
                print("\(error.localizedDescription)")
                self.locationLabel.text = "no location found"
                return
            }
            
            guard let spots = placemarks, spots.count > 0 else {
                self.locationLabel.text = "no location found"
                return
            }
            let pm = spots[0]
            let address = "\(pm.name ?? "street") \(pm.locality ?? "city") \(pm.administrativeArea ?? "state") \(pm.postalCode ?? "zipcode")"
            self.locationLabel.text = address

        })
    }
    
    // TODO: implement a ordering feature where the user posting a meal is notified
    // somebody is looking to purchase
    @IBAction func order(_ sender: Any) {
        
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

}
