//
//  Meal.swift
//  homecooked
//
//  Created by Musab Abdullah on 10/12/21.
//

import Foundation
import UIKit
import FirebaseFirestore

let defaultLocation = FirebaseFirestore.GeoPoint(latitude: 30.28318678170686, longitude: -97.74439234690759)

class Meal {
    var meal_id: String
    var chef_id: String
    var available_from: Date
    var available_until: Date
    var ingredients: [String]
    var price: Float
    var portions: Int
    var title: String
    var location: FirebaseFirestore.GeoPoint
    
    init() {
        self.meal_id = String()
        self.chef_id = String()
        self.available_from = Date()
        self.available_until = Date()
        self.ingredients = [""]
        self.price = Float()
        self.portions = Int()
        self.title = String()
        self.location = defaultLocation
    }
    
    init(withDoc: QueryDocumentSnapshot) {
        self.meal_id = withDoc.documentID
        self.chef_id = withDoc.get("chef_id") as? String ?? "no chef"
        self.available_from = withDoc.get("available_from") as? Date ?? Date.distantPast
        self.available_until = withDoc.get("available_until") as? Date ?? Date.distantPast
        self.ingredients = withDoc.get("ingredients") as? [String] ?? ["n/a"]
        self.price = withDoc.get("price") as? Float ?? 0.0
        self.portions = withDoc.get("portions") as? Int ?? 0
        self.title = withDoc.get("title") as? String ?? "no title"
        self.location = withDoc.get("location") as? FirebaseFirestore.GeoPoint ?? defaultLocation
    }
    
    func updateProperties(withDoc: QueryDocumentSnapshot) {
        self.meal_id = withDoc.documentID
        self.chef_id = withDoc.get("chef_id") as? String ?? "no chef"
        self.available_from = withDoc.get("available_from") as? Date ?? Date.distantPast
        self.available_until = withDoc.get("available_until") as? Date ?? Date.distantPast
        self.ingredients = withDoc.get("ingredients") as? [String] ?? ["n/a"]
        self.price = withDoc.get("price") as? Float ?? 0.0
        self.portions = withDoc.get("portions") as? Int ?? 0
        self.title = withDoc.get("title") as? String ?? "no title"
        self.location = withDoc.get("location") as? FirebaseFirestore.GeoPoint ?? defaultLocation
    }
}

extension Meal: CustomStringConvertible {
    var description: String {
        return """
            \(self.meal_id)
            title: \(self.title)
            price: \(self.price)
            portions: \(self.portions)
            ingredients: \(self.ingredients)
            available_from: \(self.available_from)
            available_until: \(self.available_until)
            location: \(self.location)
        """
    }
}
