//
//  Meal.swift
//  homecooked
//
//  Created by Musab Abdullah on 10/12/21.
//

import Foundation
import UIKit
import FirebaseFirestore

class Meal {
    var meal_id: String
    var chef_id: String
    var dateAvailable: Date
    var ingredients: String
    var nutrientInfo: String
    var price: Double
    var remaining: Int
    var title: String
    
    init() {
        self.meal_id = String()
        self.chef_id = String()
        self.dateAvailable = Date()
        self.ingredients = String()
        self.nutrientInfo = String ()
        self.price = Double()
        self.remaining = Int()
        self.title = String()
    }
    
    init(withDoc: QueryDocumentSnapshot) {
        self.meal_id = withDoc.documentID
        self.chef_id = withDoc.get("chefID") as? String ?? "no chef"
        self.dateAvailable = withDoc.get("dateAvailable") as? Date ?? Date.distantPast
        self.ingredients = withDoc.get("ingredients") as? String ?? "none"
        self.nutrientInfo = withDoc.get("nutrientInfo") as? String ?? "none"
        self.price = withDoc.get("cost") as? Double ?? -9999.0
        self.remaining = withDoc.get("remaining") as? Int ?? -9999
        self.title = withDoc.get("title") as? String ?? "no title"
    }
    
    func updateProperties(withDoc: QueryDocumentSnapshot) {
        self.meal_id = withDoc.documentID
        self.chef_id = withDoc.get("chefID") as? String ?? "no chef"
        self.dateAvailable = withDoc.get("dateAvailable") as? Date ?? Date.distantPast
        self.ingredients = withDoc.get("ingredients") as? String ?? "none"
        self.nutrientInfo = withDoc.get("nutrientInfo") as? String ?? "none"
        self.price = withDoc.get("cost") as? Double ?? -9999.0
        self.remaining = withDoc.get("remaining") as? Int ?? -9999
        self.title = withDoc.get("title") as? String ?? "no title"
        // if they change the image, the url should stay the same (caching problems maybe?)
    }
}

extension Meal: CustomStringConvertible {
    var description: String {
        return "\(self.title), \(self.chef_id), \(self.meal_id)"
    }
}
