//
//  ViewController.swift
//  LoginAndMap
//
//  Created by shawn on 03/07/2018.
//  Copyright © 2018 Shawn. All rights reserved.
//


import UIKit
import GoogleMaps

class ViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: GMSMapView!
    
//    @IBOutlet weak var subView: UIView!
//    var mapView = GMSMapView()
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    
    // A default location to use when "didFailWithError" is called.
    let defaultLocation = CLLocation(latitude: 32.005603, longitude: 34.885113)
    
    //using this bool to prevent spam of reloads of the same location by "didUpdateLocations"
    var isCurrentLocationLoaded: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //initiallizing location manager
        initLocManager()
        
    }
    
    
    func initLocManager() {
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }
    
    //setting up google maps and adding the markers
    func setGoogMap(lat: Double, lon: Double) {
        
            
        
        //set the map's focus
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: 12)
        self.mapView.camera = camera
        
        self.mapView.delegate = self
        self.mapView.addSubview(self.btn_refresh)

        DispatchQueue.main.async() {
        //clear all markers off of the map
        self.mapView.clear()
       
        //showing the current position of the user on the map w/ blue marker
        let markerCurLoc = GMSMarker(position: CLLocationCoordinate2DMake(lat, lon))
        markerCurLoc.title = "Current Location"
        markerCurLoc.icon = GMSMarker.markerImage(with: UIColor.blue)
        markerCurLoc.map = self.mapView
        }

        //getting the train stations near the user with the "trainStations" struct
        TrainStations.getTrainStationsAsMarkers(location: self.currentLocation!) { (trains:[GMSMarker]) in
            for TrainObj in trains {
                //adding each marker to the map
                    TrainObj.map = self.mapView
            }
        }
        self.btn_refresh.isEnabled = true
        
    }
    
    //detecting taps o the train stations markers
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        print("didtap marker")
        if marker.title != "Current Location" {
            let alert = UIAlertController(
                title: marker.title,
                message: "Rating: \(marker.snippet!) Stars \nLatitude: \((marker.position.latitude)) \nLongitude: \((marker.position.longitude))",
                preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Open in Google Maps", style: .default, handler: { action in
                //opening up google maps w/ directions from current user's location to tapped marker's location
                self.openGoogleMaps(lat: marker.position.latitude, lon: marker.position.longitude)
            }))
            alert.addAction(UIAlertAction(title: "Open in Maps", style: .default, handler: { action in
                //opening up apple maps w/ directions from current user's location to tapped marker's location
                self.openNativeMaps(lat: marker.position.latitude, lon: marker.position.longitude, name: marker.title!)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
                //do nothing - action canceled by the user
                print("cancel")
            }))
            self.present(alert, animated: true, completion: nil)
            
            return true
        } else {
            //only when the user taps the current location marker do nothing; let the default action take place and show title "current location".
            return false
        }
    }

    //opening up apple maps w/ directions from current user's location to tapped marker's location
    func openNativeMaps(lat: Double, lon: Double, name: String) {
        let url = "http://maps.apple.com/maps?saddr=\((currentLocation?.coordinate.latitude)!),\((currentLocation?.coordinate.longitude)!)&daddr=\(lat),\(lon)"
        UIApplication.shared.open(URL(string:url)!, options: [:], completionHandler: nil)
    }
    
    //opening up google maps w/ directions from current user's location to tapped marker's location
    func openGoogleMaps(lat: Double, lon: Double) {
            let url = "http://www.google.com/maps/dir/\((currentLocation?.coordinate.latitude)!),\((currentLocation?.coordinate.longitude)!)/\(lat),\(lon)/"
            UIApplication.shared.open(URL(string:url)!, options: [:], completionHandler: nil)
        //if the user doesn't have the google maps app they'll be redirected automatically to google's website
    }

    //in case of failure in loading current location this func will load default location
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if !isCurrentLocationLoaded {
        currentLocation = defaultLocation
        setGoogMap(lat: (currentLocation?.coordinate.latitude)!, lon: (currentLocation?.coordinate.longitude)!)
        isCurrentLocationLoaded = true
        }
    }

    //after getting the user's current location this func will start loading the map by calling setGoogleMap func
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if locations.count > 0 {
            currentLocation = locations[0]
        }
        
        if !isCurrentLocationLoaded {
            setGoogMap(lat: (currentLocation?.coordinate.latitude)!, lon: (currentLocation?.coordinate.longitude)!)
            isCurrentLocationLoaded = true
        }
        
    }
    
    //showing alert in case user hasn't allowed the app to use location services
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        var title = ""
        var message = ""
        switch status {
            case CLAuthorizationStatus.restricted:
                title = "Restricted"
                message = "Your device has restricted access to location, please check your restriction in settings."
                break
            case CLAuthorizationStatus.denied:
                title = "Denided"
                message = "You denided the app's access to location, please allow location services to this app in settings."
                break
        default:
            //do nothing
            break
            
        }
        
        if title != "" && message != "" {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Go to Settings", style: .default, handler: { action in
            //prompting the user to change location services settings and taking them to the settings app to do so
            UIApplication.shared.open(URL(string:"App-Prefs:root=Privacy&path=LOCATION")!, options: [:], completionHandler: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    @IBOutlet weak var btn_refresh: UIButton!
    @IBAction func btn_refresh(_ sender: Any) {
        btn_refresh.isEnabled = false
        setGoogMap(lat: (currentLocation?.coordinate.latitude)!, lon: (currentLocation?.coordinate.longitude)!)
    }
    
}

