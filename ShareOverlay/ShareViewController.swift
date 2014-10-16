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

    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var background: UIVisualEffectView!
    
    let ANIM_DURATION = 0.25

    override func viewDidLoad() {
        super.viewDidLoad()
        table.dataSource = self;
        table.delegate = self;

        let frame = table.frame;
        let c : CGFloat  = CGFloat(items.count);
        let h : CGFloat = 44 * c
        println("Height \(table.rowHeight) \(h)")
        table.frame = CGRect(x: frame.origin.x, y: UIScreen.mainScreen().bounds.height - h, width: frame.width, height: h)
    }

    override func viewDidDisappear(animated: Bool) {
        UIView.animateWithDuration(ANIM_DURATION, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            self.table.alpha = 0;
            self.background.alpha = 0;
            self.table.frame.origin.y = self.table.frame.origin.y + 100
            }, completion: { (ret: Bool) -> Void in
                println("Done 2 \(ret)");
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        background.alpha = 0;
        self.table.alpha = 0;
        let start = self.table.frame;
        self.table.frame.origin.y = start.origin.y + 100;

        UIView.animateWithDuration(ANIM_DURATION, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            self.background.alpha = 1.0;
            }, completion: { (ret: Bool) -> Void in
            println("Done \(ret)");
        })

        UIView.animateWithDuration(ANIM_DURATION, delay: ANIM_DURATION, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            self.table.alpha = 1.0;
            self.table.frame = start
            }, completion: { (ret: Bool) -> Void in
                println("Done \(ret)");
        })
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count;
    }
    
    let CellIndentifier: NSString = "ListPrototypeCell"
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // View recycling doesn't seem to work in Extensions. At least not with a View from the storyboard.
        // Thankfully, this list is really short.
        var cell:UITableViewCell = UITableViewCell(); //self.table.dequeueReusableCellWithIdentifier(CellIndentifier) as UITableViewCell
        cell.textLabel?.text = self.items[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.rowClicked()
    }

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
    
    // A simple function to be called whenever you click on one of the "configuration" rows.
    // Adds the current url to the ReadingList, and closes the dialog
    private func rowClicked() -> Void {
        self.getUrl() {
            (var url : NSURL?) -> Void in
            println("Got \(url)")
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
