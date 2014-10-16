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

class ShareViewController: UIViewController {
    
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
