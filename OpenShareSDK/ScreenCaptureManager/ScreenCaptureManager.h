//
//  ScreenCaptureManager.h
//  ScreenCaptureShare
//
//  Created by jia on 2017/5/23.
//  Copyright © 2017年 jia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScreenCaptureManager : NSObject

@property (nonatomic, assign) BOOL ignoreNotification;

+ (instancetype)manger;

- (void)listenUserDidTakeScreenshotNotificationCompletion:(void(^)(NSData *screenshot))completion;
- (void)cancelListen;
- (NSData *)screenShot;

@end
