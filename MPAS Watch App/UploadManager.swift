//
//  UploadManager.swift
//  JITAI-Health-DataCollection Watch App
//
//  Created by Jack on 4/26/23.
//

import Foundation
import Network


class UploadManager: NSObject, URLSessionDelegate {
    
    func upload_data(_ data: [[String : Any]]) {
        
        var jsonData : Data = Data.init()
        do {
            jsonData = try JSONSerialization.data(withJSONObject: data, options: .withoutEscapingSlashes)
        }catch {
            print(error.localizedDescription)
        }
        
        //let json_str = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)!
        //print(json_str)

        /* Not exactly sure what the point of the localURL is when uploadTask can just take a Data object
        let tempDir = FileManager.default.temporaryDirectory
        let localURL = tempDir.appendingPathComponent("throwaway")
        try? jsonData.write(to: localURL)
        */
        
        
        /*
        //MAKE SURE TO CHANGE URL
        let url = URL(string: "http://mas.cis.udel.edu/MPAS")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let config = URLSessionConfiguration.background(withIdentifier: "uniqueId")
        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        let task = session.uploadTask(with: request, from: jsonData)
        task.resume()
        */
    }
}
