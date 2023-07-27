//
//  UploadManager.swift
//  JITAI-Health-DataCollection Watch App
//
//  Created by Jack on 4/26/23.
//

import Foundation
import Network


class UploadManager: NSObject, URLSessionDelegate {
    
    var prev_completed = true
    
    func upload_data(_ data: [[String : Any]]) {
        prev_completed = false
        var jsonData : Data = Data.init()
        do {
            jsonData = try JSONSerialization.data(withJSONObject: data, options: .withoutEscapingSlashes)
        }catch {
            print(error.localizedDescription)
        }
        
        let _json_str = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)!
                
        //MAKE SURE TO CHANGE URL
        let url = URL(string: "https://mas.cis.udel.edu/MPAS")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        
        let task = session.uploadTask(with: request, from: jsonData, completionHandler: completed_upload)
        task.resume()
        //print("\n uploaded ", json_str)
    }
    
    func completed_upload(_ data: Data?, _ response: URLResponse?, _ err: Error?) {
        print("Data upload completed")
        prev_completed = true
    }
}
