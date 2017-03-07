//
//  OpenShare+Weixin.h
//  OpenShare_2
//
//  Created by jia on 16/3/22.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import "OpenShare.h"

@interface OpenShare (Weixin)

+ (BOOL)isWeixinInstalled;
+ (void)registWeixinWithAppId:(NSString *)appId;
+ (void)shareToWeixinSession:(OSMessage *)msg;
+ (void)shareToWeixinTimeLine:(OSMessage *)msg;
+ (BOOL)wx_handleOpenURL:(NSURL *)url;

@end
