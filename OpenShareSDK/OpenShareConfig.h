//
//  OpenShareConfig.h
//  SudiyiClient
//
//  Created by jia on 16/5/18.
//  Copyright © 2016年 Sudiyi. All rights reserved.
//

#import <Foundation/Foundation.h>

// 分享支持的平台
typedef NS_ENUM(NSInteger, OSPlatformCode) {
    
    kOSPlatformNone = 0,
    kOSPlatformCommon = -1,
    
    kOSPlatformQQ = 1 << 0,
    kOSPlatformQQZone = 1 << 1,
    kOSPlatformWXTimeLine = 1 << 2,
    kOSPlatformWXSession = 1 << 3,
    kOSPlatformSina = 1 << 4,
    kOSPlatformSms = 1 << 5,
    kOSPlatformEmail = 1 << 6,
    kOSPlatformCopyUrl = 1 << 7,
    kOSPlatformFacebook = 1 << 8,
    kOSPlatformTwitter = 1 << 9,
    kOSPlatformSystem = 1 << 10,
};

typedef NS_ENUM(NSInteger, OSShareState) {
    kOSStateUnknown,
    kOSStateNotInstalled,
    kOSStateSuccess,
    kOSStateFail,
};

extern NSString *const kOSQQIdentifier;
extern NSString *const kOSWeixinIdentifier;
extern NSString *const kOSSinaIdentifier;
extern NSString *const kOSFacebookIdentifier;
extern NSString *const kOSTwitterIdentifier;

extern NSString *const kOSErrorDomainSms;
extern NSString *const kOSErrorDomainQQ;
extern NSString *const kOSErrorDomainWeixin;
extern NSString *const kOSErrorDomainSina;
extern NSString *const kOSErrorDomainEmail;
extern NSString *const kOSErrorDomainFacebook;

extern NSString *const kOSQQScheme;
extern NSString *const kOSQQChatScheme;
extern NSString *const kOSWeixinScheme;
extern NSString *const kOSSinaScheme;
extern NSString *const kOSFacebookScheme;
extern NSString *const kOSTwitterScheme;

@interface OpenShareConfig : NSObject

@end
