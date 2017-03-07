//
//  OSSinaParameter.h
//  OpenShare_2
//
//  Created by jia on 16/4/27.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSResponse.h"

@interface OSSinaMediaObject : NSObject

@property (nonatomic, copy) NSString *__class;
@property (nonatomic, copy) NSString *objectID;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, strong) NSData *thumbnailData;
@property (nonatomic, copy) NSString *webpageUrl;

@end

@interface OSSinaParameter : NSObject

@property (nonatomic, copy) NSString *__class;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) NSDictionary *imageObject;

@property (nonatomic, strong) OSSinaMediaObject *mediaObject;

@end

@interface OSSinaApp : NSObject

@property (nonatomic, copy) NSString *appKey;
@property (nonatomic, copy) NSString *bundleID;

@end


@interface OSSinaTransferObject : NSObject

@property (nonatomic, copy) NSString *__class;
@property (nonatomic, strong) NSDictionary *message;
@property (nonatomic, copy) NSString *requestID;
@property (nonatomic, copy) NSString *responseID;
@property (nonatomic, assign) NSInteger statusCode;

@end

@interface OSSinaResponse : NSObject <OSResponse>

@property (nonatomic, strong) OSSinaApp *app;
@property (nonatomic, strong) OSSinaTransferObject *transferObject;
@property (nonatomic, strong) NSDictionary *userInfo;
@property (nonatomic, copy) NSString *sdkVersion;

- (BOOL)isAuth;
- (BOOL)isShare;
- (NSError *)error;

@end
