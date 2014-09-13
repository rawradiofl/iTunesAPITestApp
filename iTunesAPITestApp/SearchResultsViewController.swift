//
//  ViewController.swift
//  iTunesAPITestApp
//
//  Created by Me on 9/12/14.
//  Copyright (c) 2014 Me. All rights reserved.
//

import UIKit

class SearchResultViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, APIControllerProtocol {
    @IBOutlet weak var searchResultsTableView: UITableView!
    
    var albums = [Album]()
    var api: APIController?
    var kCellIdentifier: String = "SearchResultsCell"
    var imageCache = [String : UIImage]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        api = APIController(delegate: self)
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        api!.searchItunesFor("Beatles")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as UITableViewCell
        let album = self.albums[indexPath.row]
        
        cell.textLabel?.text = album.title
        cell.imageView?.image = UIImage(named: "Blank52")
        let formattedPrice = album.price
        let urlString = album.thumbnailImageURL
        var image = self.imageCache[urlString]
        if image == nil {
            var imageURL: NSURL = NSURL(string: urlString)
            // Download the image
            let request: NSURLRequest = NSURLRequest(URL: imageURL)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {
                (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                if error == nil {
                    image = UIImage(data: data)
                    // Store the image in the cache
                    self.imageCache[urlString] = image
                    if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) {
                        cellToUpdate.imageView?.image = image
                    }
                } else {
                    println("REQUEST ERROR: \(error.localizedDescription)")
                }
            })
        } else {
            dispatch_async(dispatch_get_main_queue(), {
                if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) {
                    cellToUpdate.imageView?.image = image
                }
            })
        }
        cell.detailTextLabel?.text = formattedPrice
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var detailsViewController: DetailsViewController = segue.destinationViewController as DetailsViewController
        var albumIndex = searchResultsTableView!.indexPathForSelectedRow()?.row
        var selectedAlbum = self.albums[albumIndex!]
        detailsViewController.album = selectedAlbum
    }

    func didReceiveAPIRestults(results: NSDictionary) {
        var resultsArr: NSArray = results["results"] as NSArray
        dispatch_async(dispatch_get_main_queue(), {
            self.albums = Album.albumsWithJSON(resultsArr)
            self.searchResultsTableView.reloadData()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }
    
}

