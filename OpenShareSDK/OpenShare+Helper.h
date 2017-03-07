//
//  OpenShare+Helper.h
//  OpenShare_2
//
//  Created by jia on 16/3/22.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import "OpenShare.h"

@interface OpenShare (Helper)

+ (NSString *)base64EncodedString:(NSString *)inputString;
+ (NSString *)base64DecodedString:(NSString *)inputString;
+ (NSString *)base64AndURLEncodedString:(NSString *)inputString;
+ (NSString *)contentTypeForImageData:(NSData *)data;
+ (NSString *)urlEncodedString:(NSString *)inputString;
+ (NSString *)urlStr:(NSDictionary *)parameters;

+ (NSURL *)base64AndURLEncodedURL:(NSURL *)url;

@end
