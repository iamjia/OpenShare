//
//  OSWXParameter.h
//  OpenShare_2
//
//  Created by jia on 16/4/27.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSResponse.h"

@interface OSWXParameter : NSObject

@property (nonatomic, copy) NSString *result;
@property (nonatomic, copy) NSString *returnFromApp;
@property (nonatomic, copy) NSString *sdkver;
@property (nonatomic, copy) NSString *command;
@property (nonatomic, assign) NSInteger scene;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, strong) NSData *fileData;
@property (nonatomic, strong) NSData *thumbData;
@property (nonatomic, assign) NSInteger objectType;
@property (nonatomic, strong) NSURL *mediaUrl; // FIXME: plist not support
@property (nonatomic, strong) NSURL *mediaDataUrl;

@end

@interface OSWXResponse : NSObject <OSResponse>

@property (nonatomic, copy) NSString *state;
@property (nonatomic, assign) NSInteger result;

- (NSError *)error;

@end