//
//  Bookmarks.swift
//  Project105
//
//  Created by Wes Johnston on 10/16/14.
//  Copyright (c) 2014 Wes Johnston. All rights reserved.
//

import Foundation

struct Bookmarks {
    static func add(url: NSURL) {
        var mySharedDefaults: NSUserDefaults = NSUserDefaults(suiteName: "firefox.bookmarks")!;
        var count : Int? = mySharedDefaults.valueForKey("bookmarkCount") as? Int;
        if (count == nil) {
            count = 0;
        }

        println("Add \(count): \(url.absoluteString)");
        mySharedDefaults.setObject(url.absoluteString, forKey: "bookmark_\(count!)")
        mySharedDefaults.setInteger(count! + 1, forKey: "bookmarkCount");
        println("DONE");
    }

    static func printList() {
        var mySharedDefaults: NSUserDefaults = NSUserDefaults(suiteName: "firefox.bookmarks")!;
        var count: Int = mySharedDefaults.valueForKey("bookmarkCount") as Int;
        for i in 0...count-1 {
            var url: String? = mySharedDefaults.valueForKey("bookmark_\(i)") as? String
            println("]=\(i)/\(count): \(url)")
        }
        
    }
}
