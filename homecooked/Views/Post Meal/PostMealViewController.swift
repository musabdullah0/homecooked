//
//  PostMealViewController.swift
//  homecooked
//
//  Created by Max Rattray on 10/20/21.
//

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

        // Do any additional setup after loading the view.
    }
    
    @IBAction func imageSelect(_ sender: Any) {
    }
    
    
    @IBAction func postMeal(_ sender: Any) {
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
