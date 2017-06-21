//
//  ScreenCaptureManager.m
//  ScreenCaptureShare
//
//  Created by jia on 2017/5/23.
//  Copyright © 2017年 jia. All rights reserved.
//

#import "ScreenCaptureManager.h"
#import "OpenShareManager.h"

@implementation ScreenCaptureManager
{
    @private
    id _screenshotObserver;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:_screenshotObserver];
}

+ (instancetype)manger
{
    static ScreenCaptureManager *s_mgr = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_mgr = [[ScreenCaptureManager alloc] init];
    });
    return s_mgr;
}

- (void)listenUserDidTakeScreenshotNotificationCompletion:(void(^)(NSData *screenshot))completion
{
    [[NSNotificationCenter defaultCenter] removeObserver:_screenshotObserver];
    __weak typeof(self) wSelf = self;
    _screenshotObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationUserDidTakeScreenshotNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        if (!wSelf.ignoreNotification && nil != completion) {
            completion(wSelf.screenShot);
        }
    }];
}

- (void)cancelListen
{
    [[NSNotificationCenter defaultCenter] removeObserver:_screenshotObserver];
}

- (NSData *)screenShot
{
    CGSize imageSize = CGSizeZero;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsPortrait(orientation))
        imageSize = [UIScreen mainScreen].bounds.size;
    else
        imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, window.center.x, window.center.y);
        CGContextConcatCTM(context, window.transform);
        CGContextTranslateCTM(context, -window.bounds.size.width * window.layer.anchorPoint.x, -window.bounds.size.height * window.layer.anchorPoint.y);
        if (orientation == UIInterfaceOrientationLandscapeLeft) {
            CGContextRotateCTM(context, M_PI_2);
            CGContextTranslateCTM(context, 0, -imageSize.width);
        } else if (orientation == UIInterfaceOrientationLandscapeRight) {
            CGContextRotateCTM(context, -M_PI_2);
            CGContextTranslateCTM(context, -imageSize.height, 0);
        } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
            CGContextRotateCTM(context, M_PI);
            CGContextTranslateCTM(context, -imageSize.width, -imageSize.height);
        }
        
        if ([window respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
            [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:YES];
        } else {
            [window.layer renderInContext:context];
        }
        
        CGContextRestoreGState(context);
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return UIImagePNGRepresentation(image);
}

@end
