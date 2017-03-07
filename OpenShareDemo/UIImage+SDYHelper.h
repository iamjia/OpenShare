//
//  UIImage+SDYHelper.h
//  SudiyiClient
//
//  Created by jia on 16/11/1.
//  Copyright © 2016年 Sudiyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (SDYHelper)

/**
 *  压缩图片到指定文件大小
 *
 *  @param bytes  目标大小（最大值）
 *
 *  @return 返回的图片文件
 */
- (NSData *)dataWithMaxCompressSizeBytes:(NSUInteger)bytes;

@end
