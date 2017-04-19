//
//  OSMessage.h
//  OpenShare_2
//
//  Created by jia on 16/5/4.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OpenShareConfig.h"


typedef NS_ENUM(NSInteger, OSMultimediaType) {
    OSMultimediaTypeUnknown,
    OSMultimediaTypeText,
    OSMultimediaTypeImage,
    OSMultimediaTypeNews, // 图片 + 文字 + 链接
    OSMultimediaTypeAudio,
    OSMultimediaTypeVideo,
    OSMultimediaTypeApp,
    OSMultimediaTypeFile
};


#pragma mark - OSMessage

@class OSDataItem;
@class OSPlatformAccount;

@interface OSMessage : NSObject

@property (nonatomic, strong) OSDataItem *dataItem; // 分享的消息内容
@property (nonatomic, assign) OSMultimediaType multimediaType;

- (instancetype)initWithOSMultimediaType:(OSMultimediaType)mediaType;

/**
 @brief	定制化app 账户

 app: 
 
 extern NSString *const kOSQQIdentifier;
 extern NSString *const kOSWeixinIdentifier;
 extern NSString *const kOSSinaIdentifier;
 
 */
- (void)configAccount:(void(^)(OSPlatformAccount *account))config forApp:(NSString *)app;
- (OSPlatformAccount *)accountForApp:(NSString *)app;

@end


#pragma mark - OSDataItem

@interface OSDataItem : NSObject

@property (nonatomic, assign) OSPlatformCode platformCode;

// 公共
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, strong) NSURL *link;
@property (nonatomic, strong) NSData *imageData; // encoded data
@property (nonatomic, strong) NSData *thumbnailData; // encoded data
@property (nonatomic, strong) NSURL *imageUrl; // 网络图片地址 imageUrl 优先
@property (nonatomic, strong) NSURL *thumbnailUrl; // 网络缩略图地址

// 新浪
@property (nonatomic, copy) NSString *sinaContent;

// 微信
@property (nonatomic, strong) NSURL *mediaDataUrl; // 视频
@property (nonatomic, strong) NSData *wxFileData; // 微信分享gif、文件
@property (nonatomic, copy) NSString *wxExtInfo; // TODO: 待查意义
@property (nonatomic, copy) NSString *wxFileExt; // TODO: 待查意义

// 短信
@property (nonatomic, strong) NSArray<NSString *> *recipients; // 短信接收者的电话
@property (nonatomic, copy) NSString *msgBody;

// 邮件
@property (nonatomic, strong) NSArray<NSString *> *toRecipients; // 收件人
@property (nonatomic, strong) NSArray<NSString *> *ccRecipients; // 抄送收件人
@property (nonatomic, copy) NSString *emailSubject;
@property (nonatomic, copy) NSString *emailBody;

// twitter
@property (nonatomic, copy) NSString *twitterContent;

// copy
@property (nonatomic, copy) NSString *copyableContent;

// 单个数据
- (void)setValue:(id)value forKey:(NSString *)key forPlatform:(OSPlatformCode)platformCode;
// 多个数据
- (void)setValueDic:(NSDictionary<NSString */*property*/, id/*object*/> *)valueDic forPlatform:(OSPlatformCode)platformCode;

@end


#pragma mark - OSPlatformAccount

@interface OSPlatformAccount : NSObject

@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *callBackName;

@end
