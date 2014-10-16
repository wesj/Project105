//
//  ReadingList.swift
//  Project105
//
//  Created by Wes Johnston on 10/15/14.
//  Copyright (c) 2014 Wes Johnston. All rights reserved.
//

import UIKit

public struct ReadingList {
    public static func printToConsole() {
        if (self.createDB()) {
            let (rows, err) = SD.executeQuery("SELECT * FROM Urls")
            if (err == nil) {
                println("Found \(rows.count) rows")
                for row in rows as [SwiftData.SDRow] {
                    let url = row.values["Url"]
                    println("Found row \(url?.value)")
                }
            } else {
                println("Error in query \(err)")
            }
        }
    }

    private static func createDB() -> Bool {
        var tables = SD.existingTables()
        if (!contains(tables.result, "Urls")) {
            let err = SD.createTable("Urls", withColumnNamesAndTypes: ["Url": .StringVal])
            if (err != nil) {
                println("Err creating db \(err)");
                return false;
            }
        }
        
        return true;
    }
    
    public static func add(url : NSURL) {
        var urlString : NSString = url.absoluteString!
        if (!self.createDB()) {
            println("Couldn't create db");
            return;
        }
        
        let err = SD.executeChange("INSERT INTO Urls (Url) VALUES (?)", withArgs: [urlString])
        if (err != nil) {
            println("Err inserting in db \(err)");
        } else {
            println("inserted \(url)")
        }
    }
}
