//
//  MapViewController.swift
//  homecooked
//
//  Created by Musab Abdullah on 11/2/21.
//

import UIKit
import MapKit
import FirebaseFirestore
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    let manager = CLLocationManager()
    var meals: [Meal] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        Firestore.firestore().collection("meals").getDocuments { (snapshot, err) in
            if let err = err {
                print("can't get docs \(err.localizedDescription)")
                return
            }
            for doc in snapshot!.documents {
                if let location = doc.get("location") as? FirebaseFirestore.GeoPoint {
                    let title = doc.get("title") as? String ?? "no title"
                    let chef_id = doc.get("chef_id") as? String ?? "no id"
                    let userDocRef = Firestore.firestore().collection("users").document(chef_id)
                    
                    let meal = Meal(withDoc: doc)
                    
                    userDocRef.getDocument { (doc, err) in
                        var name = ""
                        if let doc = doc, doc.exists {
                            name = doc.data()?["name"] as? String ?? "no name"
                        } else {
                            print("cant find user doc")
                        }
                        
                        
//                        let annotation = MKPointAnnotation()
                        let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                        let annotation = MealAnnotation(meal: meal, coordinate: coordinate)
                        annotation.title = title
                        annotation.subtitle = name
//                        annotation.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                        self.mapView.addAnnotation(annotation)
                    }
                }
                
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        manager.desiredAccuracy = kCLLocationAccuracyBest // watch out for battery
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            manager.stopUpdatingLocation()
            render(location)
        }
    }
    
    func render(_ location: CLLocation) {
        // zoom in map to location
        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude,
                                                longitude: location.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    

}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("clicked on meal annotation")
        
        guard let mealAnnotation = view.annotation as? MealAnnotation else {return}
        let destinationVC = self.storyboard?.instantiateViewController(identifier: "mealDetailsVC") as! MealDetailsViewController

        print(mealAnnotation.meal)
        destinationVC.displayMeal = mealAnnotation.meal
        self.present(destinationVC, animated: true, completion: nil)
//        performSegue(withIdentifier: "mapToMealDetailSegue", sender: self)
        

    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MealAnnotation else {return nil}
        let identifier = "Meal"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            let btn = UIButton(type: .detailDisclosure)
            annotationView?.rightCalloutAccessoryView = btn
        } else {
            annotationView?.annotation = annotation
        }
        return annotationView
    }
}
