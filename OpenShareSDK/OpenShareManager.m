//
//  OpenShareManager.m
//  OpenShare_2
//
//  Created by jia on 16/5/3.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import "OpenShareManager.h"
#import "OpenShareHeader.h"
#import "UIWindow+TCHelper.h"
#import "TCHTTPRequestCenter.h"
#import "OSPlatformController.h"
#import "OSResponse.h"
#import "SVProgressHUD.h"
#import "UIImage+SDYHelper.h"

@interface OpenShareManager () <OSPlatformControllerDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>
{
    @private
    OSPlatformController *_platformCtrler;
    __weak id _shareFinishObsvr;
    
}

@property (nonatomic, assign) OSPlatformCode platform;
@property (nonatomic, strong) OSMessage *message;
@property (nonatomic, copy) OSShareCompletionHandle shareCompletionHandle;

@end

@implementation OpenShareManager

+ (instancetype)defaultManager
{
    static OpenShareManager *mgr = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mgr = [[self alloc] init];
    });
    
    return mgr;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:_shareFinishObsvr];
}

- (id)init
{
    if (self = [super init]) {
        __weak typeof(self) wSelf = self;
        _shareFinishObsvr = [[NSNotificationCenter defaultCenter] addObserverForName:kOSShareFinishedNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            NSObject<OSResponse> *response = note.object;
            [wSelf callShareCompletionHandle:nil == response.error ? kOSStateSuccess : kOSStateFail error:response.error];
        }];
    }
    return self;
}

- (BOOL)shareMsg:(OSMessage *)msg platformCodes:(NSArray<NSNumber/*OSPlatformCode*/ *> *)codes completion:(OSShareCompletionHandle)completion
{
    NSArray *validCodes = [self.class validPlatformCodes:codes];
    if (validCodes.count < 1) {
        return NO;
    }
    
    _message = msg;
    _shareCompletionHandle = completion;
    _platformCtrler = [[OSPlatformController alloc] initWithPlatformCodes:validCodes];
    _platformCtrler.delegate = self;
    _platformCtrler.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    if (nil != _message.dataItem.imageUrl || nil != _message.dataItem.thumbnailUrl) {
        [self downloadImage];
    } else {
        [self showPlatformController];
    }
    
    return YES;
}

- (BOOL)shareScreenShotMsg:(OSMessage *)msg platformCodes:(NSArray<NSNumber/*OSPlatformCode*/ *> *)codes completion:(OSShareCompletionHandle)completion
{
    NSArray *validCodes = [self.class validPlatformCodes:codes];
    if (validCodes.count < 1) {
        return NO;
    }
    
    _message = msg;
    _shareCompletionHandle = completion;
    _platformCtrler = [[OSPlatformController alloc] initWithPlatformCodes:validCodes screenShot:[UIImage imageWithData:msg.dataItem.imageData]];
    _platformCtrler.delegate = self;
    _platformCtrler.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self showPlatformController];
    
    return YES;
}

+ (NSArray<NSNumber/*OSPlatformCode*/ *> *)validPlatformCodes:(NSArray<NSNumber/*OSPlatformCode*/ *> *)codes
{
    if (codes.count < 1) {
        return codes;
    }
    
    NSMutableArray *arry = codes.mutableCopy;;
    
    NSNumber *qq = @(kOSPlatformQQ);
    NSNumber *qqzone = @(kOSPlatformQQZone);
    if (([arry containsObject:qq] || [arry containsObject:qqzone]) && !OpenShare.isQQInstalled) {
        [arry removeObject:qq];
        [arry removeObject:qqzone];
    }
    
    NSNumber *wxs = @(kOSPlatformWXSession);
    NSNumber *wxt = @(kOSPlatformWXTimeLine);
    if (([arry containsObject:wxs] || [arry containsObject:wxt]) && !OpenShare.isWeixinInstalled) {
        [arry removeObject:wxs];
        [arry removeObject:wxt];
    }
    
    NSNumber *sinawb = @(kOSPlatformSina);
    if ([arry containsObject:wxs] && !OpenShare.isSinaWeiboInstalled) {
        [arry removeObject:sinawb];
    }
    
    NSNumber *fb = @(kOSPlatformFacebook);
    if ([arry containsObject:fb] && !OpenShare.isFacebookInstalled) {
        [arry removeObject:fb];
    }
    
    NSNumber *tw = @(kOSPlatformTwitter);
    if ([arry containsObject:tw] && !OpenShare.isTwitterInstalled) {
        [arry removeObject:tw];
    }
    
    if (!MFMessageComposeViewController.canSendText) {
        [arry removeObject:@(kOSPlatformSms)];
    }
    
    return arry.count > 0 ? (arry.count == codes.count ? codes : arry) : nil;
}


#pragma mark - OSPlatformControllerDelegate

- (void)OSPlatformController:(OSPlatformController *)ctrler didSelectPlatformItem:(OSPlatformItem *)platform
{
//    [self dismissPlatformController];
    
    if (nil != _uiDelegate && [_uiDelegate respondsToSelector:@selector(didSelectPlatformItem:message:)]) {
        [_uiDelegate didSelectPlatformItem:platform message:_message];
    }
    _platform = platform.code;
    
    switch (platform.code) {
        case kOSPlatformQQ: {
            [OpenShare shareToQQ:_message];
            break;
        }
        case kOSPlatformQQZone: {
            [OpenShare shareToQQZone:_message];
            break;
        }
        case kOSPlatformWXSession: {
            [OpenShare shareToWeixinSession:_message];
            break;
        }
        case kOSPlatformWXTimeLine: {
            [OpenShare shareToWeixinTimeLine:_message];
            break;
        }
        case kOSPlatformSina: {
            [OpenShare shareToSinaWeibo:_message];
            break;
        }
        case kOSPlatformEmail: {
            [OpenShare shareToMail:_message delegate:self];
            break;
        }
        case kOSPlatformSms: {
            [OpenShare shareToSms:_message delegate:self];
            break;
        }
        case kOSPlatformCopyUrl : {
            NSParameterAssert(nil != _message.dataItem.copyableContent);
            if (nil != _message.dataItem.copyableContent) {
                [UIPasteboard generalPasteboard].string = _message.dataItem.copyableContent;
                _platform = kOSPlatformCopyUrl;
                [self callShareCompletionHandle:kOSStateSuccess error:nil];
            }
            
            break;
        }
        case kOSPlatformFacebook: {
            [OpenShare shareToFacebook:_message];
            break;
        }
        case kOSPlatformTwitter: {
            [OpenShare shareToTwitter:_message];
            break;
        }
        default:
            break;
    }
}

- (void)OSPlatformControllerWillDismiss:(OSPlatformController *)ctrler
{
    [self dismissPlatformController];
}

- (void)showPlatformController
{
    UIViewController *viewController = [UIApplication sharedApplication].delegate.window.topMostViewController;
    
    // alertController
    if ([viewController isKindOfClass:[UIAlertController class]]) {
        return;
    }
    
    UITabBarController *tabCtrler = viewController.tabBarController;
    if (nil != tabCtrler) {
        viewController = tabCtrler;
    }
    
    // 修正横屏时，frame还是竖屏的情况
    CGRect rect = viewController.view.frame;
    CGAffineTransform transform = viewController.view.transform;
    if (!CGAffineTransformIsIdentity(transform)) {
        CGFloat width = rect.size.width;
        rect.size.width = rect.size.height;
        rect.size.height = width;
    }
    
    _platformCtrler.view.frame = rect;
    
    [viewController beginAppearanceTransition:NO animated:YES];
    [viewController endAppearanceTransition];
    [viewController addChildViewController:_platformCtrler];
    [_platformCtrler beginAppearanceTransition:YES animated:YES];
    [viewController.view addSubview:_platformCtrler.view];
    [_platformCtrler didMoveToParentViewController:viewController];
    [_platformCtrler endAppearanceTransition];
}

- (void)dismissPlatformController
{
    UIViewController *parentCtrler = _platformCtrler.parentViewController;
    [_platformCtrler beginAppearanceTransition:NO animated:YES];
    [_platformCtrler.view removeFromSuperview];
    [_platformCtrler endAppearanceTransition];
    [_platformCtrler willMoveToParentViewController:nil];
    [_platformCtrler removeFromParentViewController];
    
    [parentCtrler beginAppearanceTransition:YES animated:YES];
    [parentCtrler endAppearanceTransition];
    _platformCtrler = nil;
}

- (void)downloadImage
{
    // thumbnailurl 和 imageurl 理论上是不共存的。如果都设置了的话，imageUrl 优先
    NSURL *url = nil != _message.dataItem.imageUrl ? _message.dataItem.imageUrl : _message.dataItem.thumbnailUrl;
    if (nil != url) {
        NSString *path = [[self.class defaultCacheDirectoryInDomain:@"OSImageCache"] stringByAppendingPathComponent:url.absoluteString.MD5_16];
        TCHTTPCachePolicy *policy = [[TCHTTPCachePolicy alloc] init];
        policy.cacheTimeoutInterval = kTCHTTPRequestCacheNeverExpired;
        policy.shouldExpiredCacheValid = NO;
        
        TCHTTPStreamPolicy *streamPolicy = [[TCHTTPStreamPolicy alloc] init];
        streamPolicy.shouldResumeDownload = YES;
        streamPolicy.downloadDestinationPath = path;
        
        __weak typeof(_message) wMessage = _message;
        id<TCHTTPRequest> request = [[TCHTTPRequestCenter defaultCenter] requestForDownload:url.absoluteString
                                                                               streamPolicy:streamPolicy
                                                                                cachePolicy:policy];
        if (nil != request) {
            request.timeoutInterval = 20.0f;
            request.observer = self;
            
            __weak typeof(self) wSelf = self;
            request.resultBlock = ^(id<TCHTTPRequest> request, BOOL success) {
                
                if (nil == wSelf) {
                    return;
                }

                NSData *data = nil;
                if (success) {
                    data = [NSData dataWithContentsOfFile:(NSString *)request.responseObject];
                    if (nil == wMessage.dataItem.imageUrl) {
                        @autoreleasepool {
                            UIImage *image = [UIImage imageWithData:data];
                            data = [image dataWithMaxCompressSizeBytes:50 * 1024];
                        }
                    }
                }
                
                if (nil != wSelf.uiDelegate && [wSelf.uiDelegate respondsToSelector:@selector(didDownloadImage)]) {
                    [wSelf.uiDelegate didDownloadImage];
                }
                
                if (nil != wMessage && wMessage == wSelf.message) {
                    
                    if (nil != data) {
                        if (nil != wMessage.dataItem.imageUrl) {
                            wMessage.dataItem.imageData = data;
                        } else {
                            wMessage.dataItem.thumbnailData = data;
                        }
                    }
                    
                    [wSelf showPlatformController];
                }
            };
            
            if ([request start:NULL]) {
                if (nil != wSelf.uiDelegate && [wSelf.uiDelegate respondsToSelector:@selector(willDownloadImage)]) {
                    [wSelf.uiDelegate willDownloadImage];
                }
            }
        }
    }
}


#pragma mark - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    NSError *error = nil;
    if (MessageComposeResultSent != result) {
        error = [NSError errorWithDomain:kOSErrorDomainSms
                                    code:result
                                userInfo:nil];
    }
    _platform = kOSPlatformSms;
    [self callShareCompletionHandle:nil == error ? kOSStateSuccess : kOSStateFail error:error];
}


#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
    _platform = kOSPlatformEmail;
    [self callShareCompletionHandle:nil == error ? kOSStateSuccess : kOSStateFail error:error];
}


#pragma mark -

- (void)callShareCompletionHandle:(OSShareState)state error:(NSError *)error
{
    // 消失
    [self dismissPlatformController];
    
    if (nil != _shareCompletionHandle) {
        _shareCompletionHandle(_platform, _message, state, error);
        _shareCompletionHandle = nil;
    }
}

@end
