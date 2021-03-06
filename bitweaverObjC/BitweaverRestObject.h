//
//  BitweaverRestObject.h
//  Liberty
//
//  Created by Christian Fowler on 11/15/11.
//  Copyright 2011 Viovio.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BitweaverRestObject : NSObject {
}

+ (NSString *) generateUuid;
- (BOOL) createDirectory:(NSString *)directory;

// REST Mappable properties
@property (nonatomic,strong) NSString *uuId;    // Universal Unique ID for content, created by your app
@property (nonatomic,strong) NSNumber *contentId; // Content ID created by remote system
@property (nonatomic,strong) NSNumber *userId; // User ID on the remote system that created the content
@property (nonatomic,strong) NSString *title; // Title of the content
@property (nonatomic,strong) NSString *displayUri; // URL of the 
@property (nonatomic,strong) NSDate *dateCreated;
@property (nonatomic,strong) NSDate *dateLastModified;


+ (NSString *) generateUuid;
- (NSDictionary*)getAllPropertyMappings;
- (NSDictionary*)getSendablePropertyMappings;
- (void)loadFromRemoteProperties:(NSDictionary *)remoteHash;

@end

