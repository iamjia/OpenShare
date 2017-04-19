//
//  OSQQParameter.m
//  OpenShare_2
//
//  Created by jia on 16/4/27.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import "OSQQParameter.h"
#import "OpenShareConfig.h"

@implementation OSQQParameter

+ (TCMappingOption *)tc_mappingOption
{
    static TCMappingOption *opt = nil;
    
    if (nil == opt) {
        opt = [[TCMappingOption alloc] init];
        opt.nameCodingMapping = @{PropertySTR(desc): @"description"};
    }
    
    return opt;
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    return self.tc_copy;
}

@end

@implementation OSQQResponse

+ (TCMappingOption *)tc_mappingOption
{
    static TCMappingOption *opt = nil;
    
    if (nil == opt) {
        opt = [[TCMappingOption alloc] init];
        opt.nameMapping = @{PropertySTR(errorCode): @"error"};
    }
    
    return opt;
}

- (NSError *)error
{
    NSError *error = nil;
    if (0 != self.errorCode) {
        NSDictionary *userInfo = [NSDictionary dictionary];
        if (nil != _error_description) {
            userInfo = @{NSLocalizedFailureReasonErrorKey: @"share failed",
                         NSLocalizedDescriptionKey: _error_description};
        }
        
        error = [NSError errorWithDomain:kOSErrorDomainQQ
                                    code:_errorCode
                                userInfo:userInfo];
    }
    return error;
}


@end
