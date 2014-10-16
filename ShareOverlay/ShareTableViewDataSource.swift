//
//  ShareTableViewDataSource.swift
//  Project105
//
//  Created by Wes Johnston on 10/16/14.
//  Copyright (c) 2014 Wes Johnston. All rights reserved.
//

import UIKit

class ShareTableViewDataSource: NSObject, UITableViewDataSource {
    private let types : [String] = [
        "Send to device",
        "Add bookmark",
        "Add to reading list"
    ];
    
    func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            var cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier("MyCell") as UITableViewCell
            return cell;
    }
    
    func tableView(tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
            return types.count
    }
}
