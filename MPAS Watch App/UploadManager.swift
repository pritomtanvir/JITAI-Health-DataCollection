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
        
        let str = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)!
        print(str)

        /*
        let tempDir = FileManager.default.temporaryDirectory
        let localURL = tempDir.appendingPathComponent("throwaway")
        try? jsonData.write(to: localURL)
        
        //MAKE SURE TO CHANGE URL
        let url = URL(string: "https://mas.cis.udel.edu/jitai/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let config = URLSessionConfiguration.background(withIdentifier: "uniqueId")
        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        let task = session.uploadTask(with: request, fromFile: localURL)
        task.resume()
         */
    }
}
