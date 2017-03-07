//
//  UIImage+SDYHelper.m
//  SudiyiClient
//
//  Created by jia on 16/11/1.
//  Copyright © 2016年 Sudiyi. All rights reserved.
//

#import "UIImage+SDYHelper.h"

@implementation UIImage (SDYHelper)

- (NSData *)dataWithMaxCompressSizeBytes:(NSUInteger)bytes
{
    if (bytes < 1) {
        return nil;
    }
    
    CGFloat compressQuality = 1.0f;
    static const CGFloat minQuality = 0.4f;
    static const CGFloat qualityDelta = 0.2f;
    
    NSData *data = nil;
    
    do {
        @autoreleasepool {
            if (compressQuality <= minQuality) {
                break;
            }
            
            data = UIImageJPEGRepresentation(self, compressQuality);
            if (data.length <= bytes) {
                break;
            }
            compressQuality = MAX(compressQuality - qualityDelta, minQuality);
        }
    } while (YES);
    
    // 如果压缩完成的data没有满足目标bytes，那么返回nil
    if (nil != data && data.length > bytes) {
        data = nil;
    }
    
    return data;
}

@end
