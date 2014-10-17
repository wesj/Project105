//
//  ShareViewController.swift
//  ShareOverlay
//
//  Created by Wes Johnston on 10/15/14.
//  Copyright (c) 2014 Wes Johnston. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices

class ShareViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var items: [String] = ["Send to device", "Bookmark Page", "Add to reading list"]
    var images: [String] = ["overlay_send_tab_icon.png", "overlay_bookmark_icon.png", "overlay_readinglist_icon.png"]

    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var listContainer: UIView!
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var urlView: UILabel!

    let ANIM_DURATION = 0.5

    override func loadView() {
        super.loadView()
        listContainer.alpha = 0;
        background.alpha = 0;

        var myExtensionContext : NSExtensionContext = self.extensionContext!
        var inputItems = myExtensionContext.inputItems
        
        for item in inputItems as [NSExtensionItem] {
            setTitle(item.attributedContentText?.string as String?)
            for attachment in item.attachments as [NSItemProvider] {
                attachment.loadItemForTypeIdentifier(kUTTypeURL as NSString, options: nil) {
                    (decoder: NSSecureCoding!, error: NSError!) -> Void in

                    // This is semi-async, and if we find the text late, the extension view doesn't update. Need a better solution here
                    if let url : NSURL = (decoder as? NSURL) {
                        self.setUrl(url.absoluteString!);
                    } else {
                        self.setUrl("");
                    }
                }

                let options: [NSObject : AnyObject] = [
                    NSItemProviderPreferredImageSizeKey: imageView.frame.width
                ];

                attachment.loadPreviewImageWithOptions(options) {
                    (decoder: NSSecureCoding!, error: NSError!) -> Void in
                    if let image : UIImage = (decoder as? UIImage) {
                        self.imageView.image = image;
                    }
                }

                /* Doesn't work :(
                attachment.loadItemForTypeIdentifier(kUTTypeImage as NSString, options: nil) {
                (decoder: NSSecureCoding!, error: NSError!) -> Void in
                self.imageView.image = decoder as? UIImage
                }
                */
            }
        }

        setupListHeight();
        setupContainerHeight();
    }

    private func setTitle(title: NSString?) {
        if (title == nil) {
            titleView.text = "";
            return;
        }
        titleView.text = title;
    }
    
    private func setUrl(url: NSString) {
        urlView!.text = url
    }
    
    private func setupContainerHeight() {
        let frame = listContainer.frame;
        let h : CGFloat = imageView.frame.height; // table.frame.height;// +
        listContainer.frame = CGRect(x: frame.origin.x, y: UIScreen.mainScreen().bounds.height - h, width: frame.width, height: h)
    }
    
    private func setupListHeight() {
        let frame = table.frame;
        let c : CGFloat  = CGFloat(items.count);
        let h : CGFloat = 44 * c
        table.frame = CGRect(x: frame.origin.x, y: UIScreen.mainScreen().bounds.height - h, width: frame.width, height: h)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.dataSource = self;
        table.delegate = self;
    }
    
    override func viewDidAppear(animated: Bool) {
        let start = self.listContainer.frame;
        self.listContainer.frame.origin.y = start.origin.y + 100;

        UIView.animateWithDuration(ANIM_DURATION, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                self.background.alpha = 1.0;
                self.listContainer.alpha = 1.0;
                self.listContainer.frame = start
            }, completion: { (ret: Bool) -> Void in
        })
    }
    
    override func viewDidDisappear(animated: Bool) {
        UIView.animateWithDuration(ANIM_DURATION, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            self.background.alpha = 0;
            self.listContainer.alpha = 0;
            self.listContainer.frame.origin.y = self.listContainer.frame.origin.y + 100;
            }, completion: { (ret: Bool) -> Void in
        })
        self.extensionContext!.completeRequestReturningItems([], completionHandler: nil)
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // View recycling doesn't seem to work in Extensions. At least not with a View from the storyboard.
        // Thankfully, this list is really short.
        var cell:ShareListCellTableViewCell = ShareListCellTableViewCell();
        cell.textLabel?.text = self.items[indexPath.row]
        cell.shareImageView?.image = UIImage(named: self.images[indexPath.row])
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row == 0) {
            self.getUrl() {
                (var url : NSURL?) -> Void in
                if (url != nil) {
                    Bookmarks.add(url!);
                    Bookmarks.printList();
                    /* We could post some JSON to the server
                    var url : NSURL = NSURL(string: "http://www.google.com")!
                    var request: NSURLRequest = NSURLRequest(URL:url)
                    let config = NSURLSessionConfiguration.defaultSessionConfiguration()
                    let session = NSURLSession(configuration: config)
                    let task : NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: {(data, response, error) in
                        println("Got \(error): \(response)");
                    });
                    task.resume()
                    */
                    self.viewDidDisappear(true);
                }
            }
        } else {
            self.rowClicked()
        }
    }
/* Left over from using the built in share UI
    func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    func didSelectPost() {
        ReadingList.printToConsole()
        getUrl() {
            (var url : NSURL?) -> Void in
            if (url != nil) {
                ReadingList.add(url!)
            }
            self.extensionContext!.completeRequestReturningItems([], completionHandler: nil)
        }
    }
    
    func configurationItems() -> [AnyObject]! {
        var items : [SLComposeSheetConfigurationItem] = [];
        
        var item : SLComposeSheetConfigurationItem = SLComposeSheetConfigurationItem()
        item.title = "Add bookmark";
        item.value = "My value";
        item.tapHandler = rowClicked
        items.append(item)

        var item2 : SLComposeSheetConfigurationItem = SLComposeSheetConfigurationItem()
        item2.title = "Add to reading list";
        item2.tapHandler = openApp
        items.append(item2)

        return items;
    }

    private func openApp() {
    }
*/
    // A simple function to be called whenever you click on one of the "configuration" rows.
    // Adds the current url to the ReadingList, and closes the dialog
    private func rowClicked() -> Void {
        self.getUrl() {
            (var url : NSURL?) -> Void in
            if (url != nil) {
                ReadingList.add(url!);
                ReadingList.printToConsole()
                self.extensionContext!.completeRequestReturningItems([], completionHandler: nil)
            }
        }
    }
    
    // Get the url passed to us from the sharing app
    // Takes a callback function
    private func getUrl(callback: (NSURL?) -> Void) {
        var myExtensionContext : NSExtensionContext = self.extensionContext!
        var inputItems = myExtensionContext.inputItems

        for item in inputItems as [NSExtensionItem] {
            for attachment in item.attachments as [NSItemProvider] {
                attachment.loadItemForTypeIdentifier(kUTTypeURL as NSString, options: nil) {
                    (decoder: NSSecureCoding!, error: NSError!) -> Void in
                    callback(decoder as? NSURL);
                }
            }
        }
    }

}
