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
    CGSize imageSize = CGSizeZero;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
//    if (UIInterfaceOrientationIsPortrait(orientation))
        imageSize = [UIScreen mainScreen].bounds.size;
//    else
//        imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, window.center.x, window.center.y);
        CGContextConcatCTM(context, window.transform);
        CGContextTranslateCTM(context, -window.bounds.size.width * window.layer.anchorPoint.x, -window.bounds.size.height * window.layer.anchorPoint.y);
//        if (orientation == UIInterfaceOrientationLandscapeLeft) {
//            CGContextRotateCTM(context, M_PI_2);
//            CGContextTranslateCTM(context, 0, -imageSize.width);
//        } else if (orientation == UIInterfaceOrientationLandscapeRight) {
//            CGContextRotateCTM(context, -M_PI_2);
//            CGContextTranslateCTM(context, -imageSize.height, 0);
//        } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
////            CGContextRotateCTM(context, M_PI);
////            CGContextTranslateCTM(context, -imageSize.width, -imageSize.height);
//        }s
        
        if ([window respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
            [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:YES];
        } else {
            [window.layer renderInContext:context];
        }
        CGContextRestoreGState(context);
        
        
        NSArray *windows = [[UIApplication sharedApplication] windows];
        NSUInteger currentWindowIndex = [windows indexOfObject:window];
        if (windows.count > currentWindowIndex + 1)
        {
            UIWindow *nextWindow = [windows objectAtIndex:currentWindowIndex + 1];
            if (nextWindow.windowLevel > UIWindowLevelStatusBar) {
            [self mergeStatusBarToContext:context rect:CGRectMake(0.0f, 0.0f, imageSize.width, imageSize.height) screenshotOrientation:orientation];
            }
        }
        else
        {
            [self mergeStatusBarToContext:context rect:CGRectMake(0.0f, 0.0f, imageSize.width, imageSize.height)  screenshotOrientation:orientation];
        }
        
        
    }
    


    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return UIImagePNGRepresentation(image);
}

- (void)mergeStatusBarToContext:(CGContextRef)context
                           rect:(CGRect)rect
          screenshotOrientation:(UIInterfaceOrientation)o
{
    UIView *statusBarView = UIView.statusBar;
    UIInterfaceOrientation statusBarOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    CGAffineTransform preTransform = CGAffineTransformIdentity;
    if (o == statusBarOrientation)
    {
        preTransform = CGAffineTransformTranslate(preTransform, -rect.origin.x, -rect.origin.y);
    }
    //Handle status bar orientation in portrait and portrait upside down screen shot
    else if((o == UIInterfaceOrientationPortrait && statusBarOrientation == UIInterfaceOrientationLandscapeLeft) ||
            (o == UIInterfaceOrientationPortraitUpsideDown && statusBarOrientation == UIInterfaceOrientationLandscapeRight))
    {
        preTransform = CGAffineTransformTranslate(preTransform, 0, rect.size.height);
        preTransform = CGAffineTransformRotate(preTransform, - M_PI_2);
        preTransform = CGAffineTransformTranslate(preTransform, CGRectGetMaxY(rect) - screenHeight, -rect.origin.x);
    }
    else if((o == UIInterfaceOrientationPortrait && statusBarOrientation == UIInterfaceOrientationLandscapeRight) ||
            (o == UIInterfaceOrientationPortraitUpsideDown && statusBarOrientation == UIInterfaceOrientationLandscapeLeft))
    {
        preTransform = CGAffineTransformTranslate(preTransform, 0, rect.size.height);
        preTransform = CGAffineTransformRotate(preTransform, M_PI_2);
        preTransform = CGAffineTransformTranslate(preTransform, -CGRectGetMaxY(rect), rect.origin.x - screenWidth);
    }
    else if((o == UIInterfaceOrientationPortrait && statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown) ||
            (o == UIInterfaceOrientationPortraitUpsideDown && statusBarOrientation == UIInterfaceOrientationPortrait))
    {
        preTransform = CGAffineTransformTranslate(preTransform, 0, rect.size.height);
        preTransform = CGAffineTransformRotate(preTransform, - M_PI);
        preTransform = CGAffineTransformTranslate(preTransform, rect.origin.x - screenWidth, CGRectGetMaxY(rect) - screenHeight);
    }
    //Handle status bar orientation in landscape left and landscape right screen shot
    else if((o == UIInterfaceOrientationLandscapeLeft && statusBarOrientation == UIInterfaceOrientationPortrait) ||
            (o == UIInterfaceOrientationLandscapeRight && statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown))
    {
        preTransform = CGAffineTransformTranslate(preTransform, 0, rect.size.height);
        preTransform = CGAffineTransformRotate(preTransform, M_PI_2);
        preTransform = CGAffineTransformTranslate(preTransform, -CGRectGetMaxY(rect), rect.origin.x - screenHeight);
    }
    else if((o == UIInterfaceOrientationLandscapeLeft && statusBarOrientation == UIInterfaceOrientationLandscapeRight) ||
            (o == UIInterfaceOrientationLandscapeRight && statusBarOrientation == UIInterfaceOrientationLandscapeLeft))
    {
        preTransform = CGAffineTransformTranslate(preTransform, 0, rect.size.height);
        preTransform = CGAffineTransformRotate(preTransform, M_PI);
        preTransform = CGAffineTransformTranslate(preTransform, rect.origin.x - screenHeight, CGRectGetMaxY(rect) - screenWidth);
    }
    else if((o == UIInterfaceOrientationLandscapeLeft && statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown) ||
            (o == UIInterfaceOrientationLandscapeRight && statusBarOrientation == UIInterfaceOrientationPortrait))
    {
        preTransform = CGAffineTransformTranslate(preTransform, 0, rect.size.height);
        preTransform = CGAffineTransformRotate(preTransform, - M_PI_2);
        preTransform = CGAffineTransformTranslate(preTransform, CGRectGetMaxY(rect) - screenWidth, -rect.origin.x);
    }
    
    // -renderInContext: renders in the coordinate space of the layer,
    // so we must first apply the layer's geometry to the graphics context
    CGContextSaveGState(context);
    // Apply pre transform
    CGContextConcatCTM(context, preTransform);
    // Center the context around the window's anchor point
    CGContextTranslateCTM(context, [statusBarView center].x, [statusBarView center].y);
    // Apply the view transform about the anchor point
    CGContextConcatCTM(context, [statusBarView transform]);
    // Offset by the portion of the bounds left of and above the anchor point
    CGContextTranslateCTM(context,
                          -[statusBarView bounds].size.width * [[statusBarView layer] anchorPoint].x,
                          -[statusBarView bounds].size.height * [[statusBarView layer] anchorPoint].y);
    
    // Render the layer hierarchy to the current context
    [[statusBarView layer] renderInContext:context];
    
    // Restore the context
    CGContextRestoreGState(context);
}


@end
