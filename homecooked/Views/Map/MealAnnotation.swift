import MapKit

class MealAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var meal: Meal
    var title: String?
    var subtitle: String?

    init(meal: Meal, coordinate: CLLocationCoordinate2D) {
        self.meal = meal
        self.coordinate = coordinate
    }
}
