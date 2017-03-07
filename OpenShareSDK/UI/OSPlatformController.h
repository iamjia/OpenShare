//
//  OSPlatformController.h
//  OpenShare_2
//
//  Created by jia on 16/5/3.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenShareConfig.h"

@class OSPlatformItem;
@protocol OSPlatformControllerDelegate;
@interface OSPlatformController : UIViewController

@property (nonatomic, weak) id<OSPlatformControllerDelegate> delegate;

- (instancetype)initWithPlatformCodes:(NSArray<NSNumber/*OSPlatformCode*/ *> *)codes;

@end

@protocol OSPlatformControllerDelegate <NSObject>

@optional
- (void)OSPlatformController:(OSPlatformController *)ctrler didSelectPlatformItem:(OSPlatformItem *)platform;
- (void)OSPlatformControllerWillDismiss:(OSPlatformController *)ctrler;

@end

@interface OSPlatformItem : NSObject

@property (nonatomic, copy) NSString *displayName; // 展示字段（国际化）
@property (nonatomic, strong) UIImage *displayIcon;
@property (nonatomic, assign) OSPlatformCode code;

@end