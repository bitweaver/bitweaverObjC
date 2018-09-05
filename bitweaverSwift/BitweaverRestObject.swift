//  Converted to Swift 4 by Swiftify v4.1.6809 - https://objectivec2swift.com/
//
//  BitweaverRestObject.swift
//  Liberty
//
//  Created by Christian Fowler on 11/15/11.
//  Copyright 2011 Viovio.com. All rights reserved.
//

import Foundation

class BitweaverRestObject: NSObject {
    // REST Mappable properties
    @objc dynamic var uuId:String = ""            /* Universal Unique ID for content, created by your app */
    @objc dynamic var contentId: NSNumber?    /* Content ID created by remote system */
    @objc dynamic var userId: NSNumber?       /* User ID on the remote system that created the content */
    @objc dynamic var title:String = ""           /* Title of the content */
    @objc dynamic var displayUri:String = ""      /* URL of the */
    @objc dynamic var dateCreated: Date?
    @objc dynamic var dateLastModified: Date?

    func getAllPropertyMappings() -> [String : String]? {
        var mappings = [
            "content_id" : "contentId",
            "user_id" : "userId",
            "date_created" : "dateCreated",
            "date_last_modified" : "dateLastModified",
            "uuid" : "uuId",
            "display_uri" : "displayUri"
        ]
        if let sendableProperties = getSendablePropertyMappings() {
            for (k, v) in sendableProperties {
                mappings[k] = v
            }
        }
        return mappings
    }

    func getSendablePropertyMappings() -> [String : String]? {
        var mappings = [
            "title" : "title"
        ]
        return mappings
    }

    class func generateUuid() -> String? {
        return UUID().uuidString
    }
    
    func createDirectory(_ directory: String?) -> Bool {
        var ret = true
        
        let fileManager = FileManager.default
        var fileError: Error? = nil
        
        // Create the root bookPath
        if !(fileManager.fileExists(atPath: directory ?? "")) {
            if (try? fileManager.createDirectory(atPath: directory ?? "", withIntermediateDirectories: true, attributes: nil)) == nil {
                ret = false
                if let anError = fileError {
                    print("\(anError)")
                }
            }
        }
        return ret
    }
    
    func load(fromRemoteProperties remoteHash: [String : Any]?) {
        if let properties = getAllPropertyMappings() {
            for (key,value) in remoteHash! {
                let propertyName = properties[key]
                if responds(to: NSSelectorFromString(propertyName!)) {
                    setValue(remoteHash?[key], forKey: propertyName ?? "")
                    //            NSLog(@"loadRemote %@ %@ %@", key, propertyName, [remoteHash objectForKey:key] );
                }
            }
        }
    }
}