//
//  OpenShare+Sms.h
//  OpenShare_2
//
//  Created by jia on 16/5/3.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import "OpenShare.h"
#import <MessageUI/MessageUI.h>

@interface OpenShare (Sms)

+ (void)shareToSms:(OSMessage *)msg delegate:(id<MFMessageComposeViewControllerDelegate>)delegate;

@end
