//
//  ConnectionManager.swift
//  MyLibrary
//
//  Created by Samita Mandwe on 12/30/18.
//

import UIKit

class ConnectionManager: NSObject {
    
    func requestGetAPIService(searchString: String, criteria : String, success: @escaping (NSDictionary)->(), failure : @escaping (String)->()) {
        
        let encodedString = searchString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let urlString = BASE_URL + "\(criteria):" + "\(encodedString!)" + "&maxResults=40"
        let url = URL(string: urlString)
        var request = URLRequest(url:url!)
        request.httpMethod = "GET"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if error != nil {
                if let errorMsg = error?.localizedDescription {
                    failure(errorMsg)
                }
            }
            else {
                do{
                    let  jsonResult = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary

                    success(jsonResult)
                }
                catch let error as NSError {
                    DispatchQueue.main.async(execute: { () -> Void in
                         failure(error.localizedDescription)
                    })
                }
            }
        }
        task.resume()
    }
    
    func downloadImage(imgURL : String, completion: @escaping (UIImage)->()) {
        
        let imgURL = URL(string: imgURL)
        let task = URLSession.shared.downloadTask(with: imgURL!) { localURL, urlResponse, error in
            if let localURL = localURL {
                if let data = try? Data(contentsOf: localURL) {
                    if let img = UIImage(data: data) {
                        DispatchQueue.main.async(execute: { () -> Void in
                            completion(img)
                        })
                    }
                }
            }
        }
        task.resume()
    }
}
