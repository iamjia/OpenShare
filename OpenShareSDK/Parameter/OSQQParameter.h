//
//  OSQQParameter.h
//  OpenShare_2
//
//  Created by jia on 16/4/27.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSResponse.h"

@interface OSQQParameter : NSObject <NSCopying>

@property (nonatomic, copy) NSString *thirdAppDisplayName;
@property (nonatomic, copy) NSString *version;
@property (nonatomic, copy) NSString *callback_type;
@property (nonatomic, copy) NSString *callback_name;
@property (nonatomic, copy) NSString *generalpastboard;
@property (nonatomic, copy) NSString *src_type;
@property (nonatomic, copy) NSString *shareType;
@property (nonatomic, assign) NSInteger cflag;
@property (nonatomic, copy) NSString *file_type;
@property (nonatomic, copy) NSString *file_data;
@property (nonatomic, copy) NSString *objectlocation;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, strong) NSData *previewimagedata;
@property (nonatomic, strong) NSURL *url;  // 音频所在的网页地址
@property (nonatomic, strong) NSURL *flashurl; // 聊天窗口播放用的音频地址
@property (nonatomic, copy) NSString *sdkv;
@end

@interface OSQQResponse : NSObject <OSResponse>

@property (nonatomic, copy) NSString *source_scheme;
@property (nonatomic, copy) NSString *source;
@property (nonatomic, copy) NSString *version;
@property (nonatomic, copy) NSString *error_description;
@property (nonatomic, assign) NSInteger errorCode;

- (NSError *)error;

@end
