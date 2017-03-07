//
//  OpenShare+Mail.h
//  OpenShare_2
//
//  Created by jia on 16/5/3.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import "OpenShare.h"
#import <MessageUI/MessageUI.h>

@interface OpenShare (Mail)

+ (void)shareToMail:(OSMessage *)msg delegate:(id<MFMailComposeViewControllerDelegate>)delegate;

@end
