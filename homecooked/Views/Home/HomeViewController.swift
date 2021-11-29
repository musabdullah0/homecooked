//
//  HomeViewController.swift
//  homecooked
//
//  Created by Musab Abdullah on 10/11/21.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseStorageUI
import FirebaseAuth

class HomeViewController: UIViewController {
    
    var mealsRef: CollectionReference!
    var storageRef: StorageReference!

//    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var mealTableView: UITableView!
    @IBOutlet weak var postMealBtn: UIButton!
    var meals: [Meal] = []
//    var categories: [String] = ["All", "Nearby", "Cheap", "Healthy", "Asian", "Desi", "American", "Thai"]
    @IBOutlet weak var titleView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postMealBtn.layer.cornerRadius = 10
        postMealBtn.clipsToBounds = true
        titleView.layer.cornerRadius = 10
        titleView.layer.masksToBounds = true
        mealTableView.delegate = self
        mealTableView.dataSource = self
        mealsRef = Firestore.firestore().collection("meals")
        mealsRef.addSnapshotListener { (mealsSnapshot, error) in
            self.mealSnapshotListener(mealsSnapshot: mealsSnapshot, error: error)

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
                if mealToAdd.chef_id != Auth.auth().currentUser?.uid {
                    self.meals.append(mealToAdd)
                }
            }
            if (diff.type == .modified) {
                let docId = diff.document.documentID
                if let indexOfMealToModify = self.meals.firstIndex(where: { $0.meal_id == docId} ) {
                    let mealToModify = self.meals[indexOfMealToModify]
                    mealToModify.updateProperties(withDoc: diff.document)
                }
            }
            if diff.type == .removed {
                let docId = diff.document.documentID
                if let indexOfMealToRemove = self.meals.firstIndex(where: { $0.meal_id == docId} ) {
                    self.meals.remove(at: indexOfMealToRemove)
                }
            }
            DispatchQueue.main.async {
                self.mealTableView.reloadData()
            }
        }
    }
    
    func getMeals() {
        mealsRef.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let meal = Meal(withDoc: document)
                    self.meals.append(meal)
                }
                DispatchQueue.main.async {
                    self.mealTableView.reloadData()
                }
                
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mealDetailsSegueIdentifier",
           let destination = segue.destination as? MealDetailsViewController,
           let mealIndex = mealTableView.indexPathForSelectedRow?.row {
            destination.displayMeal = meals[mealIndex]
        }
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let meal = meals[indexPath.row]
        let cell = mealTableView.dequeueReusableCell(withIdentifier: "MealCellIdentifier") as! MealTableViewCell
        
        let reference = storageRef.child("\(meal.meal_id).jpg")
        cell.mealImage.sd_setImage(with: reference, placeholderImage: UIImage(named: "placeholderMeal.png"))
        cell.mealTitle.text = meal.title
        cell.mealCost.text = "$\(meal.price)"
        cell.mealRemaining.text = "\(meal.portions) remaining"
        
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
}

//extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return categories.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = categoryCollectionView.dequeueReusableCell(withReuseIdentifier: "category", for: indexPath) as! CategoryCollectionViewCell
//        cell.categoryButton.setTitle(categories[indexPath.row], for: .normal)
//        return cell
//    }
//
//
//}
