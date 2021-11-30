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
    
    var cart: [Order] = []
    var posted: [OrderCounter] = []
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    var showingCart = true
    
    override func viewDidLoad() {
        
        mealsRef = Firestore.firestore().collection("meals")
        
        mealsRef.addSnapshotListener { (mealsSnapshot, error) in
            self.mealSnapshotListener(mealsSnapshot: mealsSnapshot, error: error)

        }
        
        ordersRef = Firestore.firestore().collection("orders")
        
        ordersRef.addSnapshotListener { (cartSnapshot, error) in
            self.orderSnapshotListener(cartSnapshot: cartSnapshot, error: error)
        }

        let storage = Storage.storage()
        storageRef = storage.reference()
        
    }
    
    func mealSnapshotListener(mealsSnapshot: QuerySnapshot?, error: Error?) {
        guard let snapshot = mealsSnapshot else {
            print("no meals?")
            return
        }
        
        snapshot.documentChanges.forEach { diff in
            if diff.type == .added {
                let mealToAdd = Meal(withDoc: diff.document)
                if mealToAdd.chef_id == Auth.auth().currentUser?.uid {
                    let counter = OrderCounter(meal: mealToAdd)
                    self.posted.append(counter)
                }
            }
            if diff.type == .removed {
                let docId = diff.document.documentID
                if let indexOfMealToRemove = self.posted.firstIndex(where: { $0.meal.meal_id == docId} ) {
                    self.posted.remove(at: indexOfMealToRemove)
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func orderSnapshotListener(cartSnapshot: QuerySnapshot?, error: Error?) {
        guard let snapshot = cartSnapshot else {
            print("no cart orders?")
            return
        }
        snapshot.documentChanges.forEach { diff in

            if (diff.type == .added){
                // add to cart
                if let customerID = diff.document.get("customer_id") as? String,
                   customerID == Auth.auth().currentUser?.uid,
                   let meal_id = diff.document.get("meal_id") as? String,
                   let chef_id = diff.document.get("chef_id") as? String {
                    
                    mealsRef.document(meal_id).getDocument { (document, error) in
                        if let document = document, document.exists {
                            let meal = Meal(withDoc: document)
                            let order = Order(order_id: diff.document.documentID, chef_id: chef_id, customer_id: customerID, meal: meal)
                            self.cart.append(order)
                            self.tableView.reloadData()
                        } else {
                            print("Document does not exist")
                        }
                    }
                }
                // order for me
                if let chefID = diff.document.get("chef_id") as? String,
                   chefID == Auth.auth().currentUser?.uid,
                   let meal_id = diff.document.get("meal_id") as? String {
                    
                    if let orderIndex = self.posted.firstIndex(where: { $0.meal.meal_id == meal_id}) {
                        self.posted[orderIndex].count += 1
                        self.tableView.reloadData()
                    }
                    
                }
            }
            if diff.type == .removed {
                if let meal_id = diff.document.get("meal_id") as? String {
                    if let indexOfMealToRemove = self.cart.firstIndex(where: { $0.meal.meal_id == meal_id} ) {
                        self.cart.remove(at: indexOfMealToRemove)
                        self.tableView.reloadData()
                    }
                    if let indexOfMealToRemove = self.posted.firstIndex(where: { $0.meal.meal_id == meal_id} ) {
                        self.posted[indexOfMealToRemove].count -= 1
                        self.tableView.reloadData()
                    }
                }
            }

        }
    }
    
    @IBAction func segmentSwitch(_ sender: Any) {
        switch segmentControl.selectedSegmentIndex
        {
        case 0:
            showingCart = true
        case 1:
            showingCart = false
        default:
            break
        }
        tableView.reloadData()
        
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "save profile alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        self.present(alert, animated: true, completion: nil)
    }
}

extension OrdersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (showingCart) {
            return cart.count
        } else {
            return posted.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (showingCart){
            let meal = cart[indexPath.row].meal
            let cell = tableView.dequeueReusableCell(withIdentifier: "CartCellIdentifier") as! CartTableViewCell

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
        }
        else {
            let meal = posted[indexPath.row].meal
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostedMealCellIdentifier") as! PostedMealTableViewCell

            let reference = storageRef.child("\(meal.meal_id).jpg")
            cell.mealImage.sd_setImage(with: reference, placeholderImage: UIImage(named: "placeholderMeal.png"))
            cell.mealTitle.text = meal.title
            cell.mealCount.text = "\(posted[indexPath.row].count) order(s)"
            
            // Create Date Formatter
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YY, MMM d, hh:mm"
            let fromStr = dateFormatter.string(from: meal.available_from)
            let untilStr = dateFormatter.string(from: meal.available_until)
            cell.mealStartTime.text = fromStr
            cell.mealEndTime.text = untilStr

            return cell
        }
        
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if (showingCart) {
                let order = cart[indexPath.row]
                ordersRef.document(order.order_id).delete() { err in
                    if let err = err {
                        print("error deleting order from cart \(err)")
                    } else {
                        print("deleted order from cart")
                    }
                }
                cart.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            } else {
                if (posted[indexPath.row].count > 0) {
                    showAlert(message: "can't delete a meal that already has orders on it")
                } else {
                    let meal = posted[indexPath.row].meal
                    mealsRef.document(meal.meal_id).delete() { err in
                        if let err = err {
                            print("Error removing document: \(err)")
                        } else {
                            print("successfully deleted \(meal.title)")
                        }
                    }
                }
                self.posted.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
                
            }
            
        }
    }
}
