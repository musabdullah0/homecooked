//
//  Order.swift
//  homecooked
//
//  Created by Musab Abdullah on 11/29/21.
//

import FirebaseFirestore
import Firebase

class Order {
    var order_id: String
    var chef_id: String
    var customer_id: String
    var meal: Meal
    
    init(order_id: String, chef_id: String, customer_id: String, meal: Meal) {
        self.order_id = order_id
        self.chef_id = chef_id
        self.customer_id = customer_id
        self.meal = meal
    }
}
