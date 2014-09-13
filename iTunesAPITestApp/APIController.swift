//
//  APIController.swift
//  iTunesAPITestApp
//
//  Created by Me on 9/12/14.
//  Copyright (c) 2014 Me. All rights reserved.
//

import Foundation

protocol APIControllerProtocol {
    func didReceiveAPIRestults(results: NSDictionary)
}

class APIController {
    var delegate: APIControllerProtocol
    
    init(delegate: APIControllerProtocol) {
        self.delegate = delegate
    }
    
    func get(path: String) {
        let url = NSURL(string: path)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url, completionHandler: {data, response, error -> Void in
            println("Task completed")
            if (error != nil) {
                // There was an error with the web request. Print it to the console
                println(error.localizedDescription)
            }
            var err: NSError?
            var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as NSDictionary
            if (err != nil) {
                //there was an error parsing the json. Report it to the console
                println("JSON ERROR: \(err?.localizedDescription)")
            }
            let results: NSArray = jsonResult["results"] as NSArray
            self.delegate.didReceiveAPIRestults(jsonResult)
        })
        task.resume()
    }

    func searchItunesFor(searchTerm: String) {
        // The iTunes API expects multiple terms to be separated by + symbols
        let itunesSearchTerm = searchTerm.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        
        // Escape anything that needs escaping
        if let escapedSearchTerm = itunesSearchTerm.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding) {
            let urlPath = "https://itunes.apple.com/search?term=\(escapedSearchTerm)&media=music&entity=album"
            get(urlPath)
        }
    }
    
    func lookupAlbum(collectionId: Int) {
        get("https://itunes.apple.com/lookup?id=\(collectionId)&entity=song")
    }
}