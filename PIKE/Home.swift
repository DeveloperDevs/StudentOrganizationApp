//
//  Home.swift
//
//  Created by Devin Lee on 4/19/18.
//  Copyright © 2018 Devin Lee. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import FirebaseAuth
import FirebaseDatabase

class Home: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet var mapView: MKMapView!
    
    let users = Database.database().reference().child("users")
    
    /* An instance of locationManager */
    let locationManager = CLLocationManager()
    var startLocation: CLLocation!
    var lastLocation: CLLocation!
    var startDate: Date!
    var traveledDistance: Double = 0
    /*
     * Upon loading the view
     */
    override func viewDidLoad() {
        super.viewDidLoad( )
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            locationManager.startMonitoringSignificantLocationChanges()
            locationManager.distanceFilter = 10
            mapView.showsUserLocation = true
            mapView.userTrackingMode = .follow
        }
        
        
        /* 
         * Set up locationManager, set managers delegate to track user's location
         * and monitor regions. Configure location tracking for best accuracy
         */
        locationManager.delegate = self;
        locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        /*
         * Set up mapView delegate for additional drawing
         * Ask mapView to show user location and follow this location
         * Show user's location via storyboard.
         */
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        
        /* Set up test data */
        setupData()
    }
    
    /*
     * Upon displaying the view. We check authorization status here to recheck after
     * user's visit their settings to change stuff.
     */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        /*
         * If status is not determined, we will request authorization
         */
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        }
       
        /*
         * If denied previously, inform user that app will work better if location services are allowed
         */
        else if CLLocationManager.authorizationStatus() == .denied {
            showAlert(Message: "Location services were previously denied. Please enable location services for this app in Settings.")
        }
        
        /*
         * If authorization given, start updating location
         */
        else if CLLocationManager.authorizationStatus() == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
    
    /*
     * Set up test data
     */
    func setupData() {
        var safeCoordinate: CLLocationCoordinate2D
        safeCoordinate = CLLocationCoordinate2D(latitude: 0,longitude: 0)
        
        var homeAddress = ""
        
        Auth.auth().addStateDidChangeListener({ (Auth, User) in
            /* If someone is logged in, load data */
            if Auth.currentUser != nil /* let user = FIRAuth.auth()!.currentUser */ {
                self.users.child(Auth.currentUser!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    let value = snapshot.value as? NSDictionary
                    if (value?["homeAddress"] != nil) {
                        
                        homeAddress = (value!["homeAddress"] as? String)!
                        
                        /* Check if region monitoring is supported */
                        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
                            
                            /*  Test restaurant for the tutorial */
                            let title = "PetStore"
                            let title2 = "Home Zone"
                            let coordinate = CLLocationCoordinate2DMake(38.8681122, -77.1420097)
                            let regionRadius = 280.0
                            
                            print(homeAddress)
                            /*convert address to long/lat*/
                            let geocoder = CLGeocoder()
                            geocoder.geocodeAddressString(homeAddress) {
                                placemarks, error in
                                let placemark = placemarks?.first
                                let lat = placemark?.location?.coordinate.latitude
                                let lon = placemark?.location?.coordinate.longitude
                                print("Lat: \(lat), Lon: \(lon)")
                                safeCoordinate = CLLocationCoordinate2DMake(lat!, lon!)
                                print("HELLOOO")
                                /* Create a safe region that the app will monitor */
                                let safeRegion = CLCircularRegion(center: CLLocationCoordinate2D(latitude: safeCoordinate.latitude, longitude: safeCoordinate.longitude), radius: regionRadius, identifier: title2)
                                self.locationManager.startMonitoring(for: safeRegion)
                                
                                /* Set up an annotation for the center of the region */
                                let safeAnnotation = MKPointAnnotation()
                                safeAnnotation.coordinate = safeCoordinate;
                                safeAnnotation.title = "\(title2)";
                                self.mapView.addAnnotation(safeAnnotation)
                                print("SAFEEE")
                                print(safeCoordinate.latitude)
                                /* Add a circle on the map to represent the region's boundaries */
                                let safeCircle = MKCircle(center: safeCoordinate, radius: regionRadius)
                                self.mapView.add(safeCircle)
                                
                                
                                /* Create a region that the app will monitor */
                                let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude), radius: regionRadius, identifier: title)
                                self.locationManager.startMonitoring(for: region)
                                
                                /* Set up an annotation for the center of the region */
                                let restaurantAnnotation = MKPointAnnotation()
                                restaurantAnnotation.coordinate = coordinate;
                                restaurantAnnotation.title = "\(title)";
                                self.mapView.addAnnotation(restaurantAnnotation)
                                
                                /* Add a circle on the map to represent the region's boundaries */
                                let circle = MKCircle(center: coordinate, radius: regionRadius)
                                self.mapView.add(circle)
                            }
                        } else {
                            print("System can't track regions")
                        }
                    }
                })
            }
                /* Otherwise, no one logged in... */
            else {
                let failureAlert = UIAlertController(title: "You need to register or log in", message: "Click the login button to do so", preferredStyle: .alert)
                failureAlert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: { (action:UIAlertAction) in
                }))
                /* Present to view controller */
                self.present(failureAlert, animated: true, completion: nil)
            }
        })
    }
    
    /*
     * If status is not determined, we will request authorization
     */
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let circleRenderer = MKCircleRenderer(overlay: overlay)
        circleRenderer.strokeColor = UIColor.red
        circleRenderer.lineWidth = 1.0
        return circleRenderer
    }
    
    /* Notifies when a user enters the region */
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("REGION IDENTIFIER")
        print(region.identifier)
        if(region.identifier == "PetSmart"){
            self.showAlert(Message: "Entered PetStore, Earned 2 Points!")
            /* Check auth */
            Auth.auth().addStateDidChangeListener({ (Auth, User) in
                /* If someone is logged in, load data */
                if Auth.currentUser != nil {
                    /* We need to add 2 points for entering safe zone*/
                    Database.database().reference().child("users").child(Auth.currentUser!.uid).child("points").observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        /* Get the data snapshot in order to get the current points, then subtract the value */
                        let points = snapshot.value as? NSString
                        var thepoints = points?.integerValue
                        thepoints = thepoints! + 2
                        
                        /* Update database with updated value*/
                        Database.database().reference().child("users").child(Auth.currentUser!.uid).child("points").setValue("\(thepoints!)")
                    })
                }
                    /* Otherwise, no one logged in... */
                else {
                    let failureAlert = UIAlertController(title: "Message Not Sent", message: "Log In First", preferredStyle: .alert)
                    failureAlert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: { (action:UIAlertAction) in
                    }))
                    /* Present to view controller */
                    self.present(failureAlert, animated: true, completion: nil)
                }
            })
        } else {
            self.showAlert(Message: "Entered \(region.identifier)")
        }
    }
    
    /* Notifies when a user exits the region */
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        showAlert(Message: "Exited \(region.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if startDate == nil {
            startDate = Date()
        } else {
            print("elapsedTime:", String(format: "%.0fs", Date().timeIntervalSince(startDate)))
        }
        if startLocation == nil {
            startLocation = locations.first
        } else if let location = locations.last {
            //travel distance is in km
            if(traveledDistance >= 1000){
                traveledDistance -= 1000
                self.showAlert(Message: "You've traveled 1km and earned a point!")
                Auth.auth().addStateDidChangeListener({ (Auth, User) in
                    /* If someone is logged in, load data */
                    if Auth.currentUser != nil {
                        /* We need to add 2 points for entering safe zone*/
                        Database.database().reference().child("users").child(Auth.currentUser!.uid).child("points").observeSingleEvent(of: .value, with: { (snapshot) in
                            
                            /* Get the data snapshot in order to get the current points, then subtract the value */
                            let points = snapshot.value as? NSString
                            var thepoints = points?.integerValue
                            thepoints = thepoints! + 1
                            
                            /* Update database with updated value*/
                            Database.database().reference().child("users").child(Auth.currentUser!.uid).child("points").setValue("\(thepoints!)")
                        })
                    }
                        /* Otherwise, no one logged in... */
                    else {
                        let failureAlert = UIAlertController(title: "Message Not Sent", message: "Log In First", preferredStyle: .alert)
                        failureAlert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: { (action:UIAlertAction) in
                        }))
                        /* Present to view controller */
                        self.present(failureAlert, animated: true, completion: nil)
                    }
                })
            }
            traveledDistance += lastLocation.distance(from: location)
            print("Traveled Distance:",  traveledDistance)
            print("Straight Distance:", startLocation.distance(from: locations.last!))
        }
        lastLocation = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if (error as? CLError)?.code == .denied {
            manager.stopUpdatingLocation()
            manager.stopMonitoringSignificantLocationChanges()
        }
    }
    
    /* Displays an alert */
    func showAlert(Message: String) {
        let alert = UIAlertController(title: "Alert", message: Message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
   }
