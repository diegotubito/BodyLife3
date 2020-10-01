//
//  CustomerListCell.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 18/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa

class CustomerListCell: NSTableCellView {
    @IBOutlet weak var primerRenglonCell: NSTextField!
    @IBOutlet weak var timeAgoCell: NSTextField!
    @IBOutlet weak var counterLabel: NSTextField!
    @IBOutlet weak var imageIndicator: NSProgressIndicator!
 
    @IBOutlet weak var segundoRenglonCell: NSTextField!
    @IBOutlet weak var tercerRenglonCell: NSTextField!
    @IBOutlet weak var fotoCell: NSButton!
    
    var imageCache = NSCache<AnyObject, AnyObject>()

    @IBOutlet weak var separateLine : NSView!
    
    override func draw(_ dirtyRect: NSRect) {
        self.wantsLayer = true
        imageIndicator.style = .spinning
        imageIndicator.isDisplayedWhenStopped = false
        fotoCell.wantsLayer = true
        fotoCell.layer?.cornerRadius = (fotoCell.layer?.frame.width)! / 2
        
        separateLine.wantsLayer = true
        separateLine.layer?.backgroundColor = NSColor.gray.withAlphaComponent(0.2).cgColor
    }
    
    func showLoading() {
        imageIndicator.startAnimation(nil)
    }
    
    func hideLoading() {
        imageIndicator.stopAnimation(nil)
    }
    
    func loadImage(row: Int, customer: CustomerModel.Customer) {
        showLoading()
        self.fotoCell.image = #imageLiteral(resourceName: "empty")
        self.loadImage(row: row, customer: customer) { (image, correctRow) in
            DispatchQueue.main.async {
                self.hideLoading()
                if image == nil && correctRow == row {
                    self.fotoCell.image = #imageLiteral(resourceName: "empty")
                } else if correctRow == row {
                    self.fotoCell.image = image
                }
            }
        }

    }
    
    func loadImage(row: Int, customer: CustomerModel.Customer, completion: @escaping (NSImage?, Int) -> ()) {
        let url = "http://127.0.0.1:2999/v1/thumbnail?uid=\(customer.uid)"
        
        //if I have already loaded the image, there's no need to load it again.
        if let imageFromCache = imageCache.object(forKey: url as AnyObject) as? NSImage {
            //return the image previously loaded
            print("loaded from cache")
            completion(imageFromCache, row)
            return
        }
        
        let _services = NetwordManager()
        _services.get(url: url, response: { (data, error) in
            guard error == nil, let data = data else {
                completion(nil, row)
                return
            }
            
            do {
                let response = try JSONDecoder().decode(ThumbnailModel.Response.self, from: data)
                if response.thumbnails.count > 0 {
                    let image = response.thumbnails[0].thumbnailImage.convertToImage
                    self.imageCache.setObject(image!, forKey: url as AnyObject)
                    completion(image, row)
                } else {
                    completion(nil, row)
                }
            } catch {
                completion(nil, row)
            }
      })
    }
    
}
