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
    @IBOutlet weak var orderButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let storage = Storage.storage()
        storageRef = storage.reference()

        let reference = storageRef.child("\(displayMeal.meal_id).jpg")
        imageDisplay.sd_setImage(with: reference, placeholderImage: UIImage(named: "placeholderMeal.png"))
        
        mealName.text = displayMeal.title
        numPortions.text = String(displayMeal.portions)
        portionPrice.text = String(displayMeal.price)
        ingredients.text = displayMeal.ingredients.joined(separator: ",")

       
        availableFrom.date =  displayMeal.available_from
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
        
        // Temporary?
        imageDisplay.clipsToBounds = true
        imageDisplay.layer.cornerRadius = imageDisplay.frame.width / 2
        imageDisplay.layer.borderColor = UIColor.white.cgColor
        imageDisplay.layer.borderWidth = 6
        imageDisplay.contentMode = .scaleToFill
        
        orderButton.layer.cornerRadius = 8.0
    }
    
    // TODO: implement a ordering feature where the user posting a meal is notified
    // somebody is looking to purchase
    @IBAction func order(_ sender: Any) {
        let chef = displayMeal.chef_id
        let customer = Auth.auth().currentUser?.uid
        let uuid = UUID().uuidString
        
        Firestore.firestore().collection("orders").document(uuid).setData([
            "chef_id": chef,
            "customer_id": customer,
            "meal_id": self.displayMeal.meal_id,
        ]) { err in
            if let err = err {
                print("error")
                self.sendAlert()
            } else {
                print("success")
                self.displayMeal.portions -= 1
                if (self.displayMeal.portions == 0) {
                    Firestore.firestore().collection("meals").document(self.displayMeal.meal_id).delete()
                }
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func sendAlert() {
        let alert = UIAlertController(title: "Order failed", message: "An error occurred while trying to process your order." , preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        
        alert.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
