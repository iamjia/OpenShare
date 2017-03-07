//
//  OpenShare+Helper.m
//  OpenShare_2
//
//  Created by jia on 16/3/22.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import "OpenShare+Helper.h"

@implementation OpenShare (Helper)

+ (NSString *)base64AndURLEncodedString:(NSString *)inputString
{
    return [[[inputString dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:kNilOptions] stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLHostAllowedCharacterSet];
}

+ (NSURL *)base64AndURLEncodedURL:(NSURL *)url
{
    NSString *str = [self base64AndURLEncodedString:url.absoluteString];
    return nil != str ? [NSURL URLWithString:str] : nil;
}

+ (NSString *)base64EncodedString:(NSString *)inputString
{
    return [[inputString dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:kNilOptions];
}

+ (NSString *)base64DecodedString:(NSString *)inputString
{
    return [[NSString alloc ] initWithData:[[NSData alloc] initWithBase64EncodedString:inputString options:NSDataBase64DecodingIgnoreUnknownCharacters] encoding:NSUTF8StringEncoding];
}

+ (NSString *)urlEncodedString:(NSString *)inputString
{
    NSString *unencodedString = inputString;
    NSString *encodedString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)unencodedString,
                                                              NULL,
                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                              kCFStringEncodingUTF8));
    
    return encodedString;
}

+ (NSString *)urlStr:(NSDictionary *)parameters
{
    NSMutableString *urlStr = [NSMutableString string];
    for (NSString *key in parameters.allKeys) {
        id obj = parameters[key];
        [urlStr appendFormat:@"%@=%@&", key, obj];
    }
    
    return [urlStr substringToIndex:urlStr.length - 1];
}

+ (NSString *)contentTypeForImageData:(NSData *)data
{
    uint8_t c = 0;
    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return @"image/jpeg";
        case 0x89:
            return @"image/png";
        case 0x47:
            return @"image/gif";
        case 0x49:
        case 0x4D:
            return @"image/tiff";
        case 0x52: {
            // R as RIFF for WEBP
            if (data.length < 12) {
                return nil;
            }
            
            NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 12)] encoding:NSASCIIStringEncoding];
            if ([testString hasPrefix:@"RIFF"] && [testString hasSuffix:@"WEBP"]) {
                return @"image/webp";
            }
            return nil;
        }
            
        default:
            return nil;
    }
}


@end
