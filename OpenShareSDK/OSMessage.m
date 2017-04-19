//
//  OSMessage.m
//  OpenShare_2
//
//  Created by jia on 16/5/4.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import "OSMessage.h"
#import <objc/runtime.h>
#import "UIImage+SDYHelper.h"

#pragma mark - OSMessage

@interface OSMessage ()

@end

@implementation OSMessage
{
    @private
    NSMutableDictionary<NSString */*platform*/, OSPlatformAccount *> *_accountDic; // app配置
}

- (instancetype)initWithOSMultimediaType:(OSMultimediaType)mediaType
{
    if (self = [super init]) {
        _multimediaType = mediaType;
        _accountDic = NSMutableDictionary.dictionary;
    }
    return self;
}

- (void)configAccount:(void (^)(OSPlatformAccount *))config forApp:(NSString *)app
{
    OSPlatformAccount *account = _accountDic[app];
    if (nil == account) {
        account = [[OSPlatformAccount alloc] init];
        _accountDic[app] = account;
    }
    
    if (nil != config) {
        config(account);
    }
}

- (OSPlatformAccount *)accountForApp:(NSString *)app
{
    return _accountDic[app];
}

@end


#pragma mark - OSDataItem

static NSString *const kDefaultData = @"defaultData";

@interface OSDataItem ()

@end

@implementation OSDataItem
{
@private
    NSMutableDictionary<NSString */*property*/, NSMutableDictionary */*{platform: customValue}*/> *_dataDic;
}

@dynamic title;
@dynamic content;
@dynamic link;
@dynamic imageData;
@dynamic thumbnailData;
@dynamic imageUrl;
@dynamic thumbnailUrl;

- (instancetype)init
{
    if (self = [super init]) {
        _dataDic = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSMutableDictionary *)valueDicForProperty:(NSString *)property;
{
    NSMutableDictionary *valueDic = _dataDic[property];
    if (nil == valueDic) {
        valueDic = NSMutableDictionary.dictionary;
        _dataDic[property] = valueDic;
    }
    return valueDic;
}

- (void)setValue:(id)value forKey:(nonnull NSString *)key forPlatform:(OSPlatformCode)platformCode
{
    if (nil != value) {
        [self valueDicForProperty:key][@(platformCode)] = value;
    }
}

- (void)setValueDic:(NSDictionary<NSString *,id> *)valueDic forPlatform:(OSPlatformCode)platformCode
{
    for (NSString *key in valueDic.allKeys) {
        [self setValue:valueDic[key] forKey:key forPlatform:platformCode];
    }
}

- (id)platformValueForProperty:(NSString *)property
{
    NSMutableDictionary *valueDic = [self valueDicForProperty:property];
    id value = valueDic[@(_platformCode)];
    if (nil == value) {
        value = valueDic[@(kOSPlatformCommon)];
    }
    return value;
}

- (void)setTitle:(NSString *)title
{
    if (nil != title) {
        [self setValue:title forKey:PropertySTR(title) forPlatform:kOSPlatformCommon];
    }
}

- (void)setContent:(NSString *)content
{
    if (nil != content) {
        [self setValue:content forKey:PropertySTR(content) forPlatform:kOSPlatformCommon];
    }
}

- (void)setLink:(NSURL *)link
{
    if (nil != link) {
        [self setValue:link forKey:PropertySTR(link) forPlatform:kOSPlatformCommon];
    }
}

- (void)setImageData:(NSData *)imageData
{
    if (nil != imageData) {
        [self setValue:imageData forKey:PropertySTR(imageData) forPlatform:kOSPlatformCommon];
    }
}

- (void)setThumbnailData:(NSData *)thumbnailData
{
    if (nil != thumbnailData) {
        [self setValue:thumbnailData forKey:PropertySTR(thumbnailData) forPlatform:kOSPlatformCommon];
    }
}

- (void)setImageUrl:(NSString *)imageUrl
{
    if (nil != imageUrl) {
        [self setValue:imageUrl forKey:PropertySTR(imageUrl) forPlatform:kOSPlatformCommon];
    }
}

- (void)setThumbnailUrl:(NSString *)thumbnailUrl
{
    if (nil != thumbnailUrl) {
        [self setValue:thumbnailUrl forKey:PropertySTR(thumbnailUrl) forPlatform:kOSPlatformCommon];
    }
}

- (NSString *)title
{
    return [self platformValueForProperty:NSStringFromSelector(_cmd)];
}

- (NSString *)content
{
    return [self platformValueForProperty:NSStringFromSelector(_cmd)];
}

- (NSURL *)link
{
    return [self platformValueForProperty:NSStringFromSelector(_cmd)];
}

- (NSData *)imageData
{
    return [self platformValueForProperty:NSStringFromSelector(_cmd)];
}

- (NSData *)thumbnailData
{
    NSData *thumbnailData = [self platformValueForProperty:NSStringFromSelector(_cmd)];
 
    if (nil == thumbnailData) {
        thumbnailData = self.imageData;
    }
    // 如果存在imagedata，那么忽略掉thumbnaildata，采用imagedata来裁剪
    if (nil != thumbnailData) {
        NSUInteger bytes = 40 * 1024; // 默认40kb
        switch (_platformCode) {
            case kOSPlatformQQ:
            case kOSPlatformQQZone: {
                bytes = 1024 * 1024;
                break;
            }
            default:
                break;
        }
        
        @autoreleasepool {
            UIImage *image = [UIImage imageWithData:thumbnailData];
            thumbnailData = [image dataWithMaxCompressSizeBytes:bytes];
        }
    }
    
    return thumbnailData;
}

- (NSString *)imageUrl
{
    return [self platformValueForProperty:NSStringFromSelector(_cmd)];
}

- (NSString *)thumbnailUrl
{
    return [self platformValueForProperty:NSStringFromSelector(_cmd)];
}

- (NSString *)sinaContent
{
    if (nil == _sinaContent) {
        _sinaContent = self.customedContent;
    }
    return _sinaContent;
}

- (NSString *)emailBody
{
    if (nil == _emailBody) {
        _emailBody = self.customedContent;
    }
    return _emailBody;
}

- (NSString *)msgBody
{
    if (nil == _msgBody) {
        _msgBody = self.customedContent;
    }
    return _msgBody;
}

- (NSString *)twitterContent
{
    if (nil == _twitterContent) {
        _twitterContent = self.customedContent;
    }
    return _twitterContent;
}

- (NSString *)copyableContent
{
    if (nil == _copyableContent) {
        _copyableContent = self.customedContent;
    }
    return _copyableContent;
}

- (NSString *)customedContent
{
    NSString *customedContent = self.content ?: @"";
    if (nil != self.link) {
        customedContent = [customedContent stringByAppendingFormat:@"\x20%@", self.link];
    }
    return customedContent;
}

@end


#pragma mark - OSPlatformAccount

@implementation OSPlatformAccount : NSObject

@end

