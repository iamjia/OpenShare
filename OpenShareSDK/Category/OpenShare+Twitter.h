//
//  OpenShare+Twitter.h
//  OpenShareSDKDemo
//
//  Created by jia on 16/6/2.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import "OpenShare.h"

@interface OpenShare (Twitter)

+ (BOOL)isTwitterInstalled;
+ (void)shareToTwitter:(OSMessage *)msg;

@end
