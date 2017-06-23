//
//  UIView+StatusBar.m
//  OTNotificationViewDemo
//
//  Created by openthread on 8/9/13.
//
//

static UIView *s_statusBar = nil;

#import "UIView+StatusBar.h"

@implementation UIView (StatusBar)

+ (UIView *)statusBar
{
    return s_statusBar;
}

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class statusBarClass = NSClassFromString(@"UIStatusBar");
        [statusBarClass tc_swizzle:@selector(setFrame:)];
        [statusBarClass tc_swizzle:NSSelectorFromString(@"dealloc")];
    });
}

- (void)tc_setFrame:(CGRect)frame
{
    [self tc_setFrame:frame];
    s_statusBar = self;
}

- (void)tc_dealloc
{
    s_statusBar = nil;
    [self tc_dealloc];
}

@end
