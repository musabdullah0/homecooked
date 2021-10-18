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
    var image: UIImage
    var title: String
    var chefName: String // need to change to a relationship with a User object
    var distance: Int
    var cost: Double
    var remaining: Int
    
    init(withDoc: QueryDocumentSnapshot) {
        self.meal_id = withDoc.documentID
        self.title = withDoc.get("title") as? String ?? "no title"
        self.chefName = withDoc.get("chefName") as? String ?? "no chef"
        self.distance = withDoc.get("distance") as? Int ?? 0
        self.cost = withDoc.get("cost") as? Double ?? 1.0
        self.remaining = withDoc.get("remaining") as? Int ?? 0
        self.image = UIImage()
    }
    
    func updateProperties(withDoc: QueryDocumentSnapshot) {
        self.title = withDoc.get("title") as? String ?? "no title"
        self.chefName = withDoc.get("chefName") as? String ?? "no chef"
        self.distance = withDoc.get("distance") as? Int ?? 0
        self.cost = withDoc.get("cost") as? Double ?? 1.0
        self.remaining = withDoc.get("remaining") as? Int ?? 0
    }
}

extension Meal: CustomStringConvertible {
    var description: String {
        return "\(title), \(chefName), d-\(distance), c-\(cost), r-\(remaining)"
    }
}
