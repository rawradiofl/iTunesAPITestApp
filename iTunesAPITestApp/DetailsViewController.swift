//
//  DetailsViewController.swift
//  iTunesAPITestApp
//
//  Created by Scott Martin on 9/13/14.
//  Copyright (c) 2014 Me. All rights reserved.
//

import UIKit
import MediaPlayer
import QuartzCore


class DetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, APIControllerProtocol {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var albumCover: UIImageView!
    @IBOutlet weak var tracksTableView: UITableView!
    
    lazy var api: APIController = APIController(delegate: self)
    var album: Album?
    var tracks = [Track]()
    var mediaPlayer: MPMoviePlayerController = MPMoviePlayerController()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = self.album?.title
        albumCover.image = UIImage(data: NSData(contentsOfURL: NSURL(string: self.album!.largeImageURL)))
        if self.album != nil {
            api.lookupAlbum(self.album!.collectionId)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TrackCell") as TrackCell
        let track = tracks[indexPath.row]
        cell.titleLabel.text = track.title
        cell.playIcon.text = "▶️"
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var track = tracks[indexPath.row]

        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? TrackCell {
            if cell.playIcon.text == "▶️" {
                mediaPlayer.stop()
                mediaPlayer.contentURL = NSURL(string: track.previewUrl)
                mediaPlayer.play()
                cell.playIcon.text = "🔲"
            } else {
                mediaPlayer.stop()
                cell.playIcon.text = "▶️"
            }
            
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
        UIView.animateWithDuration(0.25, animations: {
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
        })
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? TrackCell {
            mediaPlayer.stop()
            cell.playIcon.text = "▶️"
        }
    }
    
    func didReceiveAPIRestults(results: NSDictionary) {
        var resultsArr: NSArray = results["results"] as NSArray
        dispatch_async(dispatch_get_main_queue(), {
            self.tracks = Track.tracksWithJSON(resultsArr)
            self.tracksTableView.reloadData()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }
    
}