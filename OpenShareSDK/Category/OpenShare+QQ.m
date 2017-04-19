//
//  OpenShare+QQ.m
//  OpenShare_2
//
//  Created by jia on 16/3/21.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import "OpenShare+QQ.h"
#import "OpenShare+Helper.h"
#import "OSQQParameter.h"
#import "NSObject+TCCoding.h"
#import "NSURL+TCHelper.h"

static NSString *const kOSQQPasteboardKey = @"com.tencent.mqq.api.apiLargeData";
static NSString *const kOSQQShareApi = @"share/to_fri";
static NSString *const kOSQQChatApi = @"im/chat";

@implementation OpenShare (QQ)

+ (BOOL)isQQInstalled
{
    NSURLComponents *com = [[NSURLComponents alloc] init];
    com.scheme = kOSQQScheme;
    return [self canOpenURL:com.URL];
}

+ (NSString *)callBackName
{
    return [self dataForRegistedApp:kOSQQIdentifier][@"callback_name"];
}

+ (void)registQQWithAppId:(NSString *)appId
{
    [self registAppWithName:kOSQQIdentifier
                       data:@{@"appid": appId,
                              @"callback_name": [NSString stringWithFormat: @"QQ%02llx", appId.longLongValue]}];
}

+ (void)shareToQQ:(OSMessage *)msg
{
    if ([self isAppRegisted:kOSQQIdentifier]) {
        [self openAppWithURL:[self urlWithMessage:msg flag:kOSPlatformQQ]];
    }
}

+ (void)shareToQQZone:(OSMessage *)msg
{
    if ([self isAppRegisted:kOSQQIdentifier]) {
        [self openAppWithURL:[self urlWithMessage:msg flag:kOSPlatformQQZone]];
    }
}


static OSQQParameter *s_qqParam = nil;

+ (OSQQParameter *)qqParameter
{
    if (nil == s_qqParam) {
        s_qqParam = [[OSQQParameter alloc] init];
        s_qqParam.thirdAppDisplayName = [OpenShare base64EncodedString:TCAppInfo.displayName];
        s_qqParam.version = @"1";
        s_qqParam.callback_type = @"scheme";
        s_qqParam.callback_name = self.callBackName;
        s_qqParam.generalpastboard = @"1";
        s_qqParam.src_type = @"app";
        s_qqParam.shareType = @"0";
        s_qqParam.sdkv = @"3.1";
    }
    return s_qqParam;
}

+ (NSURL *)urlWithMessage:(OSMessage *)msg flag:(NSInteger)flag
{
    s_qqParam = nil;
    
    OSDataItem *data = msg.dataItem;
    data.platformCode = flag;
    
    OSQQParameter *qqParam = self.qqParameter.copy;
    OSPlatformAccount *account = [msg accountForApp:kOSQQIdentifier];
    if (nil != account.callBackName) {
        qqParam.callback_name = account.callBackName;
    }
    
    qqParam.cflag = kOSPlatformQQ == flag ? 0 : 1;
    
    switch (msg.multimediaType) {
        case OSMultimediaTypeText: {
            qqParam.file_type = @"text";
            // 这里不需要urlencode
            qqParam.file_data = [OpenShare base64EncodedString:data.content];
            break;
        }
            
        case OSMultimediaTypeImage: {
            
            qqParam.file_type = @"img";
            qqParam.objectlocation = @"pasteboard";
            qqParam.title = [OpenShare base64EncodedString:data.title]; // 这里不需要urlencode
            qqParam.desc = [OpenShare base64AndURLEncodedString:data.content];
            
            // 不需要设置缩略图，qq自己会处理，设了也不管用
            NSMutableDictionary *pbData = NSMutableDictionary.dictionary;
            if (nil != data.imageData) {
                pbData[@"file_data"] = data.imageData;
            }
            
            [self setGeneralPasteboardData:pbData
                                    forKey:kOSQQPasteboardKey
                                  encoding:kOSPasteboardEncodingKeyedArchiver];
            break;
        }
            
        case OSMultimediaTypeNews:
        case OSMultimediaTypeAudio:
        case OSMultimediaTypeVideo: {
            if (msg.multimediaType == OSMultimediaTypeNews) {
                qqParam.file_type = @"news";
            } else if (msg.multimediaType == OSMultimediaTypeAudio) {
                qqParam.file_type = @"audio";
            } else if (msg.multimediaType == OSMultimediaTypeVideo) {
                qqParam.file_type = @"video";
            }
            
            qqParam.objectlocation = @"pasteboard";
            qqParam.title = [OpenShare base64EncodedString:data.title]; // 这里不需要urlencode
            NSAssert([[OpenShare base64DecodedString:qqParam.title] isEqualToString:data.title], @"can not decode string for qq");
            qqParam.desc = [OpenShare base64AndURLEncodedString:data.content];
            qqParam.url = [OpenShare base64AndURLEncodedURL:data.link];
            qqParam.flashurl = [OpenShare base64AndURLEncodedURL:data.mediaDataUrl];
            
            NSMutableDictionary *pbData = NSMutableDictionary.dictionary;
            if (nil != data.thumbnailData) {
                pbData[@"previewimagedata"] = data.thumbnailData;
            }
            
            [self setGeneralPasteboardData:pbData
                                    forKey:kOSQQPasteboardKey
                                  encoding:kOSPasteboardEncodingKeyedArchiver];
            break;
        }
            
        default:
            break;
    }
    
    // 修改原因，NSURLComponents 会把host percentencode，从而导致qq重启。这个url shareapi不应该被encode
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@", kOSQQScheme, kOSQQShareApi]];
    return [url appendParam:qqParam.tc_plistObject override:NO];
}

+ (BOOL)chatWithQQ:(NSString *)qq
{
    if (![self isAppRegisted:kOSQQIdentifier]) {
        return NO;
    }
    
    NSURLComponents *com = [[NSURLComponents alloc] init];
    com.scheme = kOSQQChatScheme;
    com.host = kOSQQChatApi;
    com.query = [NSString stringWithFormat:@"uin=%@&chat_type=wpa&callback_name=%@&thirdAppDisplayName=%@&src_type=app&version=1&callback_type=scheme&sdkv=2.9.3", qq, self.callBackName ?: @"QQ", [OpenShare base64EncodedString:TCAppInfo.displayName]];
    return [self openAppWithURL:com.URL];
}

+ (BOOL)QQ_handleOpenURL:(NSURL *)url
{
    BOOL canHandle = [url.scheme hasPrefix:kOSQQIdentifier];
    
    // 分享
    if (canHandle) {
        [self clearGeneralPasteboardDataForKey:kOSQQPasteboardKey];
        if ([url.absoluteString rangeOfString:self.identifier].location == NSNotFound) {
            return canHandle;
        }
        
        self.identifier = nil;
        OSQQResponse *response = [OSQQResponse tc_mappingWithDictionary:url.parseQueryToDictionary];
        [[NSNotificationCenter defaultCenter] postNotificationName:kOSShareFinishedNotification object:response];
    }
    return canHandle;
}

@end
