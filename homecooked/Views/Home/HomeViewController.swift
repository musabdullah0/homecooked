//
//  HomeViewController.swift
//  homecooked
//
//  Created by Musab Abdullah on 10/11/21.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var postMealBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postMealBtn.layer.cornerRadius = 10
        postMealBtn.clipsToBounds = true
    }

}
