//
//  MapViewController.swift
//  homecooked
//
//  Created by Musab Abdullah on 11/2/21.
//

import UIKit
import MapKit
import FirebaseFirestore

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Firestore.firestore().collection("meals").getDocuments { (snapshot, err) in
            if let err = err {
                print("can't get docs \(err.localizedDescription)")
                return
            }
            for doc in snapshot!.documents {
                let location = doc.get("location") as? FirebaseFirestore.GeoPoint ?? defaultLocation
                let title = doc.get("title") as? String ?? "no title"
                let chef_id = doc.get("chef_id") as? String ?? "no id"
                let userDocRef = Firestore.firestore().collection("users").document(chef_id)
                
                userDocRef.getDocument { (doc, err) in
                    var name = ""
                    if let doc = doc, doc.exists {
                        name = doc.data()?["name"] as? String ?? "no name"
                        print(name)
                    } else {
                        print("cant find user doc")
                    }
                    
                    
                    let annotation = MKPointAnnotation()
                    annotation.title = title
                    annotation.subtitle = name
                    annotation.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                    self.mapView.addAnnotation(annotation)
                }
                
            }
        }
    }
    

}
