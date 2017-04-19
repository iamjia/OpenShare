//
//  OpenShareFacebookParam.m
//  OpenShareSDKDemo
//
//  Created by jia on 16/6/3.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import "OpenShareFacebookParam.h"
#import "OpenShareConfig.h"

@implementation OpenShareFacebookParam

@end

@implementation OpenShareFacebookBridgeArgs

@end

@implementation OpenShareFacebookMethodArgs

+ (TCMappingOption *)tc_mappingOption
{
    static TCMappingOption *opt = nil;
    
    if (nil == opt) {
        opt = [[TCMappingOption alloc] init];
        opt.nameMapping = @{PropertySTR(desc): @"description"};
    }
    
    return opt;
}

@end

@implementation OpenShareArgPhoto

@end

@implementation OSFacebookResponse

+ (TCMappingOption *)tc_mappingOption
{
    static TCMappingOption *opt = nil;
    
    if (nil == opt) {
        opt = [[TCMappingOption alloc] init];
        opt.nameMapping = @{PropertySTR(errDic): @"error"};
    }
    
    return opt;
}

- (NSError *)error
{
    NSError *error = nil;
    if (nil != _errDic) {
        NSDictionary *userInfo = _errDic[@"userInfo"];
        NSDictionary *errInfo = @{NSLocalizedFailureReasonErrorKey: @"share failed",
                                  NSLocalizedDescriptionKey: userInfo[@"error_reason"]};
        error = [NSError errorWithDomain:kOSErrorDomainFacebook
                                    code:[userInfo[@"error_code"] integerValue]
                                userInfo:errInfo];
    }
    return error;
}


@end
