//
//  OrdersViewController.swift
//  homecooked
//
//  Created by Max Rattray on 11/28/21.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseStorageUI
import FirebaseAuth

class OrdersViewController: UIViewController {
    
    var mealsRef: CollectionReference!
    var ordersRef: CollectionReference!
    var storageRef: StorageReference!
    
    var cart: [Meal] = []
    var posted: [Meal] = []
    
    @IBOutlet weak var cartTableView: UITableView!
//    @IBOutlet weak var postedTableView: UITableView!
    
    override func viewDidLoad() {
        
        cartTableView.delegate = self
        cartTableView.dataSource = self
        
//        postedTableView.delegate = self
//        postedTableView.dataSource = self
        
        mealsRef = Firestore.firestore().collection("meals")
        ordersRef = Firestore.firestore().collection("orders")
        
        ordersRef.addSnapshotListener { (cartSnapshot, error) in
            self.cartSnapshotListener(cartSnapshot: cartSnapshot, error: error)
        }
        ordersRef.addSnapshotListener { (postedSnapshot, error) in
            self.postedSnapshotListener(postedSnapshot: postedSnapshot, error: error)
        }
        
        let storage = Storage.storage()
        storageRef = storage.reference()
        
    }
    
    func cartSnapshotListener(cartSnapshot: QuerySnapshot?, error: Error?) {
        guard let snapshot = cartSnapshot else {
            print("no cart orders?")
            return
        }
        snapshot.documentChanges.forEach { diff in

            if (diff.type == .added){
                
                if let customerID = diff.document.get("customer_id") as? String,
                   customerID == Auth.auth().currentUser?.uid {
                    
                    if let meal_id = diff.document.get("meal_id") as? String {
                        let mealDocRef = mealsRef.document(meal_id)
                        mealDocRef.getDocument { (document, error) in
                            if let document = document, document.exists {
                                    let meal = Meal(withDoc: document)
                                    self.cart.append(meal)
                                    self.cartTableView.reloadData()
                            } else {
                                print("Document does not exist")
                            }
                        }
                    }
                    
                }
            }
            if (diff.type == .modified) {
                let docId = diff.document.get("meal_id") as! String
                if let indexOfMealToModify = self.cart.firstIndex(where: { $0.meal_id == docId} ) {
                    let mealToModify = self.cart[indexOfMealToModify]
                    let mealDocRef = mealsRef.document(diff.document.get("meal_id") as! String)
                    mealDocRef.getDocument { (document, error) in
                        if let document = document, document.exists {
                            mealToModify.updateProperties(withDoc: document as! QueryDocumentSnapshot)
                        } else {
                            print("Document does not exist")
                        }
                    }
                    mealToModify.updateProperties(withDoc: diff.document)
                }
            }
            if diff.type == .removed {
                let docId = diff.document.get("meal_id") as! String
                if let indexOfMealToRemove = self.cart.firstIndex(where: { $0.meal_id == docId} ) {
                    self.cart.remove(at: indexOfMealToRemove)
                }
            }
            DispatchQueue.main.async {
                self.cartTableView.reloadData()
            }
        }
    }
    
    func postedSnapshotListener(postedSnapshot: QuerySnapshot?, error: Error?) {
        guard let snapshot = postedSnapshot else {
            print("no posted orders?")
            return
        }
        snapshot.documentChanges.forEach { diff in
            let chefID = diff.document.get("chef_id") as! String
            if diff.type == .added && chefID == Auth.auth().currentUser?.uid {
                let mealDocRef = mealsRef.document(diff.document.get("meal_id") as! String)
                mealDocRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        let mealToAdd = Meal(withDoc: document as! QueryDocumentSnapshot)
                        self.posted.append(mealToAdd)
                    } else {
                        print("Document does not exist")
                    }
                }
            }
            if (diff.type == .modified) {
                let docId = diff.document.get("meal_id") as! String
                if let indexOfMealToModify = self.posted.firstIndex(where: { $0.meal_id == docId} ) {
                    let mealToModify = self.posted[indexOfMealToModify]
                    let mealDocRef = mealsRef.document(diff.document.get("meal_id") as! String)
                    mealDocRef.getDocument { (document, error) in
                        if let document = document, document.exists {
                            mealToModify.updateProperties(withDoc: document as! QueryDocumentSnapshot)
                        } else {
                            print("Document does not exist")
                        }
                    }
                    mealToModify.updateProperties(withDoc: diff.document)
                }
            }
            if diff.type == .removed {
                let docId = diff.document.get("meal_id") as! String
                if let indexOfMealToRemove = self.posted.firstIndex(where: { $0.meal_id == docId} ) {
                    self.posted.remove(at: indexOfMealToRemove)
                }
            }
            DispatchQueue.main.async {
//                self.postedTableView.reloadData()
            }
        }
    }
}

extension OrdersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == self.cartTableView){
            return cart.count
        }
        else {
            return posted.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if (tableView == self.cartTableView){
            let meal = cart[indexPath.row]
            print("showing meal", indexPath.row)
            print(meal)
            let cell = cartTableView.dequeueReusableCell(withIdentifier: "CartCellIdentifier") as! CartTableViewCell

            let reference = storageRef.child("\(meal.meal_id).jpg")
            cell.mealImage.sd_setImage(with: reference, placeholderImage: UIImage(named: "placeholderMeal.png"))
            cell.mealTitle.text = meal.title
            cell.mealCost.text = "$\(meal.price)"
            // Create Date Formatter
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YY, MMM d, hh:mm"
            let fromStr = dateFormatter.string(from: meal.available_from)
            let untilStr = dateFormatter.string(from: meal.available_until)
            cell.mealStartTime.text = fromStr
            cell.mealEndTime.text = untilStr

            let userDocRef = Firestore.firestore().collection("users").document(meal.chef_id)

            userDocRef.getDocument { (doc, err) in
                if let doc = doc, doc.exists {
                    let name = doc.data()?["name"] as? String
                    cell.mealChefName.text = name
                } else {
                    print("Document does not exist")
                    cell.mealChefName.text = "no name"
                }
            }

            return cell
//        }
//        else {
//            let meal = posted[indexPath.row]
//            let cell = postedTableView.dequeueReusableCell(withIdentifier: "PostedMealCellIdentifier") as! PostedMealTableViewCell
//
//            let reference = storageRef.child("\(meal.meal_id).jpg")
//            cell.mealImage.sd_setImage(with: reference, placeholderImage: UIImage(named: "placeholderMeal.png"))
//            cell.mealTitle.text = meal.title
//            // Create Date Formatter
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "YY, MMM d, hh:mm"
//            let fromStr = dateFormatter.string(from: meal.available_from)
//            let untilStr = dateFormatter.string(from: meal.available_until)
//            cell.mealStartTime.text = fromStr
//            cell.mealEndTime.text = untilStr
//
//            return cell
//        }
        
    }
}
