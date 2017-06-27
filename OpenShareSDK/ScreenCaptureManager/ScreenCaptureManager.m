//
//  ScreenCaptureManager.m
//  ScreenCaptureShare
//
//  Created by jia on 2017/5/23.
//  Copyright © 2017年 jia. All rights reserved.
//

#import "ScreenCaptureManager.h"
#import "OpenShareManager.h"
#import "UIView+StatusBar.h"

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
    UIGraphicsBeginImageContextWithOptions([UIScreen mainScreen].bounds.size, NO, [UIScreen mainScreen].scale);
    
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:YES];
        
        // add statusBar
        UIView *statusBarView = UIView.statusBar;
        [statusBarView drawViewHierarchyInRect:statusBarView.bounds afterScreenUpdates:YES];
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return UIImagePNGRepresentation(image);
}

@end
