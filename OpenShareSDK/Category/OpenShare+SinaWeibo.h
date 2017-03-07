//
//  OpenShare+SinaWeibo.h
//  OpenShare_2
//
//  Created by jia on 16/3/23.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import "OpenShare.h"

@interface OpenShare (SinaWeibo)

+ (BOOL)isSinaWeiboInstalled;
+ (void)registSinaWeiboWithAppKey:(NSString *)appKey;
+ (void)shareToSinaWeibo:(OSMessage *)msg;
+ (BOOL)wb_handleOpenURL:(NSURL *)url;

@end
