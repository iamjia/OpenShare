//
//  OpenShare.h
//  OpenShare_2
//
//  Created by jia on 16/3/21.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSMessage.h"
#import "OpenShareConfig.h"

typedef NS_ENUM(NSInteger, OSPasteboardEncoding){
    kOSPasteboardEncodingNone,
    kOSPasteboardEncodingKeyedArchiver,
    kOSPasteboardEncodingPropertyListSerialization
};

extern NSString *const kOSShareFinishedNotification;

typedef void(^OSShareCompletionHandle)(OSPlatformCode platform, OSMessage *message, OSShareState state, NSError *error);

@interface OpenShare : NSObject

+ (NSString *)identifier;
+ (void)setIdentifier:(NSString *)identifier;

+ (BOOL)canOpenURL:(NSURL *)url;
+ (BOOL)openAppWithURL:(NSURL *)url;
+ (BOOL)handleOpenURL:(NSURL *)url;

+ (void)registAppWithName:(NSString *)appName data:(NSDictionary *)data;
+ (NSDictionary *)dataForRegistedApp:(NSString *)appName;
+ (BOOL)isAppRegisted:(NSString *)appName;

+ (void)setGeneralPasteboardData:(id)value forKey:(NSString *)key encoding:(OSPasteboardEncoding)encoding;
+ (NSDictionary *)generalPasteboardDataForKey:(NSString *)key encoding:(OSPasteboardEncoding)encoding;
+ (void)clearGeneralPasteboardDataForKey:(NSString *)key;

@end
