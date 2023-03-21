//
//  GeoLocationManager.swift
//  JITAI-Health-DataCollection Watch App
//
//  Created by Jack on 3/16/23.
//

import Foundation

//
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
        
    
    override init()
    {
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        super.init()
        locationManager.delegate = self
        locationManager.requestLocation()
        locationManager.requestAlwaysAuthorization()
        // Initialization, but dont start until user starts walking.
        locationManager.startUpdatingLocation()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()// if only authorized when in use
            print("Location authorized")
        }
    }
    
    // Updates current location any time location changes
    func locationManager(_ manager: CLLocationManager,  didUpdateLocations locations: [CLLocation])
    {
        self.currentLocation =  manager.location;
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
        //locationManager.requestLocation()
        let cl: CLLocation? = locationManager.location
        //currentLocation = cl
        return cl ?? currentLocation
    }
    
}

