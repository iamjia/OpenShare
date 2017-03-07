//
//  OpenShareFacebookParam.h
//  OpenShareSDKDemo
//
//  Created by jia on 16/6/3.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSResponse.h"

@class OpenShareFacebookBridgeArgs;
@class OpenShareFacebookMethodArgs;
@class OpenShareArgPhoto;

@interface OpenShareFacebookParam : NSObject

@property (nonatomic, copy) NSString *app_id;
@property (nonatomic, copy) NSString *bridge_args; // jsonstring
@property (nonatomic, copy) NSString *cipher_key; // 格式 AWtJZYTtN89/G2uR5avmiT8= 可以忽略
@property (nonatomic, copy) NSString *method_args; // jsonstring
@property (nonatomic, copy) NSString *version;

@end

@interface OpenShareFacebookBridgeArgs : NSObject

@property (nonatomic, copy) NSString *app_name;
@property (nonatomic, copy) NSString *sdk_version;
//@property (nonatomic, copy) NSString *action_id; // 可以忽略 格式 FD00775B-C03F-4A2E-9A2E-930FEF202DA9

@end

@interface OpenShareFacebookMethodArgs : NSObject

@property (nonatomic, assign) BOOL dataFailuresFatal;
@property (nonatomic, strong) NSArray<OpenShareArgPhoto *> *photos; // OpenShareArgPhoto jsonstring
@property (nonatomic, copy) NSString *desc; // description
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *link;

@end

@interface OpenShareArgPhoto : NSObject

@property (nonatomic, copy) NSString *tag;
@property (nonatomic, assign) BOOL isPasteboard;
@property (nonatomic, copy) NSString *fbAppBridgeType_jsonReadyValue;

@end

@interface OSFacebookResponse : NSObject <OSResponse>

@property (nonatomic, strong) NSDictionary *errDic;

- (NSError *)error;

@end


//{
//    "error":{
//        "user_info":{
//            "error_reason":"未能完成操作。（“FBAPIErrorDomain”错误 100。）",
//            "error_description":"Failed to authenticate the application because of app name mismatch. Please check the application name configured by the dialog.",
//            "app_id":"1102019623254542",
//            "error_code":102
//        },
//        "code":102,
//        "domain":"com.facebook.Facebook.platform"
//    },
//    "app_name":"FirstDemo",
//    "sdk_version":"4.12.0"
//}&method_args={
//    "dataFailuresFatal":false,
//    "name":"testTitle",
//    "desc":"testDes",
//    "link":"http://sina.cn?a=1"
//}
