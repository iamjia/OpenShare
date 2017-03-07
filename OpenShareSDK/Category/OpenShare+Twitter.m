//
//  OpenShare+Twitter.m
//  OpenShareSDKDemo
//
//  Created by jia on 16/6/2.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import "OpenShare+Twitter.h"
#import "OpenShare+Helper.h"

@implementation OpenShare (Twitter)

+ (BOOL)isTwitterInstalled
{
    NSURLComponents *com = [[NSURLComponents alloc] init];
    com.scheme = kOSTwitterScheme;
    return [self canOpenURL:com.URL];
}

// 暂时只支持分享文字
+ (void)shareToTwitter:(OSMessage *)msg
{
    OSDataItem *data = msg.dataItem;
    data.platformCode = kOSPlatformTwitter;
    
    NSString *content = data.twitterContent;
    
    NSURLComponents *com = [[NSURLComponents alloc] init];
    com.scheme = kOSTwitterScheme;
    com.host = @"post";
    com.query = [NSString stringWithFormat:@"message=%@", content];
    
    [self openAppWithURL:com.URL];
}

@end
