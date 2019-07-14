//
//  TrainStations.swift
//  LoginAndMap
//
//  Created by shawn on 04/07/2018.
//  Copyright © 2018 Shawn. All rights reserved.
//

import UIKit
import GoogleMaps

struct TrainStations {
    let name: String
    let rating: Double
    let lat: Double
    let lon: Double
    
    //between startURL and middleURL adding the latitude and longitude seperated by "," and after that adding ApiKey
    static let startURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location="
    static let middleURL = "&radius=100000&type=train_station&key="
    static let ApiKey = "<GOOGLE-MAPS-API-KEY>"
    
    //errors
    enum SerializationError: Error {
        case missing(String)
    }
    
    //initilizing to the values from the json
    init(json:[String:Any]) throws {
        guard let name = json["name"] as? String else {throw SerializationError.missing("couldn't find 'name'")}
        guard let rating = json["rating"] as? Double else {throw SerializationError.missing("couldn't find 'rating'")}
        
        guard let geometry = json["geometry"] as? [String:Any] else {throw SerializationError.missing("couldn't find 'geometry'")}
        guard let location = geometry["location"] as? [String:Any] else {throw SerializationError.missing("couldn't find 'location'")}
        guard let lat = location["lat"] as? Double else {throw SerializationError.missing("couldn't find 'lat'")}
        guard let lon = location["lng"] as? Double else {throw SerializationError.missing("couldn't find 'lon'")}
        
        self.name = name
        self.rating = rating
        self.lat = lat
        self.lon = lon
    }
    
    //getting the data for the train station near the user
    static func getTrainStationsAsMarkers(location: CLLocation, completion: @escaping ([GMSMarker]) -> ()) {
        //current user location
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        
        //final url that will be used to get the json
        let url = startURL + "\(lat),\(lon)" + middleURL + ApiKey
        
        let request = URLRequest(url: URL(string: url)!)
        
        let task = URLSession.shared.dataTask(with: request) { (data:Data?, response: URLResponse? ,error: Error?) in
            
            //the array that will hold the GMSMarkers of the train stations
            var trains: [GMSMarker] = []
            
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                        
                        //getting the array with the key "results" from the json
                        if let results = json["results"] as? [[String:Any]] {
                            DispatchQueue.main.async() {
                            for result in results {
                                //getting the train stations data and adding it to GMSMarkers
                                
                                if let TrainObj = try? TrainStations(json: result) {
                                        let marker = GMSMarker(position: CLLocationCoordinate2DMake(TrainObj.lat, TrainObj.lon))
                                    marker.title = TrainObj.name
                                    marker.snippet = "\(TrainObj.rating)"
                                    
                                    //adding each marker to the trains array that we will get from completion
                                    trains.append(marker)
                                    }
                                }
                                completion(trains)
                                
                            }
                            
                        }
                    }
                } catch {
                    print("Error: " + error.localizedDescription)
                }
                
                
            }
        }
        task.resume()
        
    }
    
}
