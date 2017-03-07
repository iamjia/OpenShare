//
//  OpenShareManager.h
//  OpenShare_2
//
//  Created by jia on 16/5/3.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OpenShareHeader.h"
#import "OSPlatformController.h"


@class OSMessage;
@protocol OSUIDelegate;
@interface OpenShareManager : NSObject

@property (nonatomic, weak) id<OSUIDelegate> uiDelegate;

+ (instancetype)defaultManager;

+ (NSArray<NSNumber/*OSPlatformCode*/ *> *)validPlatformCodes:(NSArray<NSNumber/*OSPlatformCode*/ *> *)codes;

- (BOOL)shareMsg:(OSMessage *)msg platformCodes:(NSArray<NSNumber/*OSPlatformCode*/ *> *)codes completion:(OSShareCompletionHandle)completion;

@end

@protocol OSUIDelegate <NSObject>

@optional
- (void)didSelectPlatformItem:(OSPlatformItem *)platform message:(OSMessage *)message;
- (void)willDownloadImage; // 有可能下载图片时间会略长，所以用户决定是否显示hud
- (void)didDownloadImage; // 图片下载完成，用户负责取消掉hud

@end