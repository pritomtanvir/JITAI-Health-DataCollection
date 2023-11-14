//  GeoLocationManager.swift
//  JITAIHealth WatchKit Extension
//
//  Created by Ajith Vemuri on 8/12/20.
//

import Foundation
import CoreLocation


class GeoLocationManager: NSObject, CLLocationManagerDelegate
{
    
    //Holds the most up to date location of the watch
    var locationManager:CLLocationManager
    var currentLocation:CLLocation?
    var updateTimer: Timer?
        
    
    override init()
    {
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyReduced
        locationManager.allowsBackgroundLocationUpdates = true
        super.init()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        //Timer.scheduledTimer(withTimeInterval: 1800.0, repeats: true) { timer in
        //    self.locationManager.startUpdatingLocation()
        //}.fire()
        locationManager.startUpdatingLocation()
    }
    
    // Updates current location any time location changes
    func locationManager(_ manager: CLLocationManager,  didUpdateLocations locations: [CLLocation])
    {
        self.currentLocation =  manager.location;
        //manager.stopUpdatingLocation()
        print("Location update")
    }
    
    // Error handling for locationManager, this method is called when user denies authorization for location
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        if let error = error as? CLError, error.code == .denied
        {
            // Location updates are not authorized.
            //manager.stopMonitoringSignificantLocationChanges() Not supported in WatchOS
            print("Fail to load location")
            print(error.localizedDescription)
            return
        }
        // Notify the user of any errors.
    }
    
    
    // This method returns the user's current location.
    func fetchCurrentLocation() -> CLLocation? {
        return currentLocation
    }
    
}

