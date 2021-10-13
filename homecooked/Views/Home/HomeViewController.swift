//
//  HomeViewController.swift
//  homecooked
//
//  Created by Musab Abdullah on 10/11/21.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var mealTableView: UITableView!
    @IBOutlet weak var postMealBtn: UIButton!
    var meals: [Meal] = []
    var categories: [String] = ["All", "Nearby", "Cheap", "Healthy", "Asian", "Desi", "American", "Thai"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postMealBtn.layer.cornerRadius = 10
        postMealBtn.clipsToBounds = true
        mealTableView.delegate = self
        mealTableView.dataSource = self
        meals = createArray()
    }
    
    func createArray() -> [Meal] {
        let fettucini = Meal(image: UIImage(named: "fettuccine") ?? UIImage(), title: "Fettucini Alfredo", chefName: "Michael Scott")
        let beets = Meal(image: UIImage(named: "beets") ?? UIImage(), title: "Roasted Beets", chefName: "Dwight Schrute")
        let tuna = Meal(image: UIImage(named: "tuna") ?? UIImage(), title: "Tuna Sandwich", chefName: "Jim Halpert")
        return [fettucini, beets, tuna]
    }

}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let meal = meals[indexPath.row]
        let cell = mealTableView.dequeueReusableCell(withIdentifier: "MealCellIdentifier") as! MealTableViewCell
        
        cell.mealImage.image = meal.image
        cell.mealTitle.text = meal.title
        cell.mealChefName.text = meal.chefName
        cell.mealDistance.text = "\(meal.distance) mi"
        cell.mealCost.text = "$\(meal.cost)"
        cell.mealRemaining.text = "\(meal.remaining) remaining"
        return cell
        
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = categoryCollectionView.dequeueReusableCell(withReuseIdentifier: "category", for: indexPath) as! CategoryCollectionViewCell
        cell.categoryLabel.text = categories[indexPath.row]
        return cell
    }
    
    
}
