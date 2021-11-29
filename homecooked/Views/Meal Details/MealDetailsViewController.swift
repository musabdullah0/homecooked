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
    var ingredientsList = [String]()
    private let kItemPadding = 15

    @IBOutlet weak var imageDisplay: UIImageView!
    @IBOutlet weak var mealName: UILabel!
    @IBOutlet weak var numPortions: UILabel!
    @IBOutlet weak var portionPrice: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var availableFrom: UIDatePicker!
    @IBOutlet weak var availableUntil: UIDatePicker!
    
    @IBOutlet weak var ingredientsCollectionView: UICollectionView!
    

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
        
//        mealName.text = displayMeal.title
//        numPortions.text = String(displayMeal.portions)
//        portionPrice.text = String(displayMeal.price)
//        ingredientsList = displayMeal.ingredients
//        print(displayMeal)
////        ingredients.text = displayMeal.ingredients.joined(separator: ",")
//        availableFrom.date =  displayMeal.available_from
//        availableUntil.date = displayMeal.available_until
        
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
        
        // ingredients bubble layout setup stuff
        let bubbleLayout = MICollectionViewBubbleLayout()
        bubbleLayout.minimumLineSpacing = 6.0
        bubbleLayout.minimumInteritemSpacing = 6.0
        bubbleLayout.delegate = self
        ingredientsCollectionView.setCollectionViewLayout(bubbleLayout, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        mealName.text = displayMeal.title
        numPortions.text = String(displayMeal.portions)
        portionPrice.text = String(displayMeal.price)
        ingredientsList = displayMeal.ingredients
        print(displayMeal)
//        ingredients.text = displayMeal.ingredients.joined(separator: ",")
        availableFrom.date =  displayMeal.available_from
        availableUntil.date = displayMeal.available_until
    }
    
    // TODO: implement a ordering feature where the user posting a meal is notified
    // somebody is looking to purchase
    @IBAction func order(_ sender: Any) {
        
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

}


extension MealDetailsViewController: MICollectionViewBubbleLayoutDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ingredientsList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let indentifier = "MIBubbleCollectionViewCell"
                
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: indentifier, for: indexPath) as? MIBubbleCollectionViewCell {
            
            cell.lblTitle.text = ingredientsList[indexPath.row]
            print("adding cell for",ingredientsList[indexPath.row])
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, itemSizeAt indexPath: NSIndexPath) -> CGSize {
        let title = ingredientsList[indexPath.row] as NSString
        var size = title.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17.0)])
         size.width = CGFloat(ceilf(Float(size.width + CGFloat(kItemPadding * 2))))
         size.height = 24
     
         //...Checking if item width is greater than collection view width then set item width == collection view width.
         if size.width > collectionView.frame.size.width {
             size.width = collectionView.frame.size.width
         }
     
         return size;
    }
    
    
}
