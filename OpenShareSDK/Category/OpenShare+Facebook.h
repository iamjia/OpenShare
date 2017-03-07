//
//  OpenShare+Facebook.h
//  OpenShareSDKDemo
//
//  Created by jia on 16/6/3.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import "OpenShare.h"
#import "OSResponse.h"

@interface OpenShare (Facebook)

+ (BOOL)isFacebookInstalled;
+ (void)registFacebookWithAppID:(NSString *)appID;
+ (void)shareToFacebook:(OSMessage *)msg;

@end
