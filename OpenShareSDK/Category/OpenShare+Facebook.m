//
//  OpenShare+Facebook.m
//  OpenShareSDKDemo
//
//  Created by jia on 16/6/3.
//  Copyright © 2016年 Jia. All rights reserved.
//

//参考文档 https://developers.facebook.com/docs/sharing/ios

#import "OpenShare+Facebook.h"
#import "OpenShareFacebookParam.h"
#import "OpenShare+Helper.h"

static NSString *const kOpenShareFBPasteboardKey = @"com.facebook.Facebook.FBAppBridgeType";
static NSString *const kFbAppName = @"Thor";


@implementation OpenShare (Facebook)

+ (BOOL)isFacebookInstalled
{
    NSURLComponents *com = [[NSURLComponents alloc] init];
    com.scheme = kOSFacebookScheme;
    return [self canOpenURL:com.URL];
}

+ (void)registFacebookWithAppID:(NSString *)appID
{
    [self registAppWithName:kOSFacebookIdentifier data:@{@"appid": appID}];
}

// Data
static OpenShareFacebookParam *s_fbParam = nil;

+ (OpenShareFacebookParam *)fbParameter
{
    if (nil == s_fbParam) {
        s_fbParam = [[OpenShareFacebookParam alloc] init];
      
        OpenShareFacebookBridgeArgs *args = [[OpenShareFacebookBridgeArgs alloc] init];
        args.app_name = kFbAppName; // fb开发者平台注册的app名字
        args.sdk_version = @"4.12.0"; // 固定
        
        s_fbParam.bridge_args = args.tc_JSONString;
    }
    return s_fbParam;
}

+ (void)shareToFacebook:(OSMessage *)msg
{
    if ([self isAppRegisted:kOSFacebookIdentifier]) {
        [self openAppWithURL:[self fbUrlWithMessage:msg]];
    }
}

+ (NSURL *)fbUrlWithMessage:(OSMessage *)msg
{
    OSDataItem *data = msg.dataItem;
    data.platformCode = kOSPlatformFacebook;
    
    OpenShareFacebookParam *fbParam = self.fbParameter;
    
    OpenShareFacebookMethodArgs *methodArgs = [[OpenShareFacebookMethodArgs alloc] init];
    methodArgs.dataFailuresFatal = NO;
    
    switch (msg.multimediaType) {
        case OSMultimediaTypeText: {
            // 不支持
            // https://developers.facebook.com/docs/apps/review/prefill
            
            break;
        }
        case OSMultimediaTypeImage: {
            /*
            1.照片大小必须小于 12MB。
            2.用户需要安装版本 7.0 或以上的原生 iOS 版 Facebook 应用。
            */
            if (nil != data.imageData) {
                [self setGeneralPasteboardData:data.imageData
                                        forKey:kOpenShareFBPasteboardKey
                                      encoding:kOSPasteboardEncodingNone];
            }
            
            OpenShareArgPhoto *photo = [[OpenShareArgPhoto alloc] init];
            photo.tag = @"png"; // 固定，不管gif，还是jpeg，还是png，fb都标记的png
            photo.isPasteboard = YES;
            photo.fbAppBridgeType_jsonReadyValue = @"com.apple.UIKit.pboard.general";
        
            methodArgs.photos = @[photo];
            break;
        }
        case OSMultimediaTypeAudio:
        case OSMultimediaTypeVideo: {
            /*
             1.视频大小必须小于 12MB。
             2.分享内容的用户应安装版本 26.0 或以上的 iOS 版 Facebook 客户端。
             */
            
            // TODO: 后续待需要时再处理
            break;
        }
        case OSMultimediaTypeNews: {
            methodArgs.name = data.title;
            methodArgs.desc = data.content;
            methodArgs.link = data.link.absoluteString;
            break;
        }
        default:
            break;
    }
 
    fbParam.method_args = methodArgs.tc_JSONString;
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    for (NSString *key in [fbParam.tc_plistObject allKeys]) {
        NSString *encodedStr = [OpenShare urlEncodedString:fbParam.tc_plistObject[key]];
        paramDic[key] = encodedStr;
    }
    
    OSPlatformAccount *account = [msg accountForApp:kOSFacebookIdentifier];
    NSString *appId = account.appId;
    if (nil == appId) {
        appId = [self dataForRegistedApp:kOSFacebookIdentifier][@"appid"];
    }
    
    if (nil == appId) {
        return nil;
    }

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@://dialog/share?app_id=%@&%@&version=20140116", kOSFacebookScheme, appId, [OpenShare urlStr:paramDic]]];
    return url;
}

+ (BOOL)fb_handleOpenURL:(NSURL *)url
{
    BOOL canHandle = [url.scheme hasPrefix:kOSFacebookIdentifier];
    
    // 分享
    if (canHandle) {
        [self clearGeneralPasteboardDataForKey:kOpenShareFBPasteboardKey];
        if ([url.absoluteString rangeOfString:self.identifier].location == NSNotFound) {
            return canHandle;
        }
        
        self.identifier = nil;
        
        OSFacebookResponse *response = [OSFacebookResponse tc_mappingWithDictionary:url.parseQueryToDictionary];
        [[NSNotificationCenter defaultCenter] postNotificationName:kOSShareFinishedNotification object:response];
    }
    return canHandle;
}


@end
