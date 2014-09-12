//
//  Album.swift
//  iTunesAPITestApp
//
//  Created by Me on 9/12/14.
//  Copyright (c) 2014 Me. All rights reserved.
//

import Foundation

class Album {
    var title: String
    var price: String
    var thumbnailImageURL: String
    var largeImageURL: String
    var itemURL: String
    var artistURL: String
    
    init(name: String, price: String, thumbnailImageURL: String, largeImageURL: String, itemURL: String, artistURL: String) {
        self.title = name
        self.price = price
        self.thumbnailImageURL = thumbnailImageURL
        self.largeImageURL = largeImageURL
        self.itemURL = itemURL
        self.artistURL = artistURL
    }
    
    class func albumsWithJSON(allresuls: NSArray) -> [Album] {
        var albums = [Album]()
        
        if (allresuls.count > 0) {
            for result in allresuls {
                // handle both tracks and collections
                var name = result["trackName"] as? String
                if (name == nil) {
                    name = result["collectionName"] as? String
                }
                
                // price can be formattedPrice or collectionPrice and be either float or String
                var price = result["formattedPrice"] as? String
                if (price == nil) {
                    price = result["collectionPrice"] as? String
                    if (price == nil) {
                        var priceFloat = result["collectionPrice"] as? Float
                        var nf: NSNumberFormatter = NSNumberFormatter()
                        nf.maximumFractionDigits = 2
                        if let pf = priceFloat {
                            price = "$" + nf.stringFromNumber(pf)
                        }
                    }
                }
                
                let thumbnailURL = result["artworkUrl60"] as? String ?? ""
                let imageURL = result["artworkUrl100"] as? String ?? ""
                let artistURL = result["artistViewUrl"] as? String ?? ""
                
                var itemURL = result["collectionViewUrl"] as? String
                if itemURL == nil {
                    itemURL = result["trackViewUrl"] as? String ?? ""
                }
                
                var newAlbum = Album(name: name!, price: price!, thumbnailImageURL: thumbnailURL, largeImageURL: imageURL, itemURL: itemURL!, artistURL: artistURL)
                albums.append(newAlbum)
            }
        }
        return albums
    }
}