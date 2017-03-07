//
//  OpenShare+QQ.h
//  OpenShare_2
//
//  Created by jia on 16/3/21.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import "OpenShare.h"

@interface OpenShare (QQ)

+ (BOOL)isQQInstalled;
+ (void)registQQWithAppId:(NSString *)appId;
+ (void)shareToQQ:(OSMessage *)msg;
+ (void)shareToQQZone:(OSMessage *)msg;
+ (BOOL)QQ_handleOpenURL:(NSURL *)url;

// qq聊天
+ (BOOL)chatWithQQ:(NSString *)qq;

@end
