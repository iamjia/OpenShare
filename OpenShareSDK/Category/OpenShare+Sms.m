//
//  OpenShare+Sms.m
//  OpenShare_2
//
//  Created by jia on 16/5/3.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import "OpenShare+Sms.h"
#import "OpenShare+Helper.h"
#import "UIWindow+TCHelper.h"

@implementation OpenShare (Sms)

+ (void)shareToSms:(OSMessage *)msg delegate:(id<MFMessageComposeViewControllerDelegate>)delegate
{
    if (MFMessageComposeViewController.canSendText) {
        msg.dataItem.platformCode = kOSPlatformSms;
        
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        controller.recipients = msg.dataItem.recipients;
        controller.body = msg.dataItem.msgBody;
        controller.messageComposeDelegate = delegate;
        if (OSMultimediaTypeImage == msg.multimediaType && nil != msg.dataItem.imageData) {
            NSString *imageType = [OpenShare contentTypeForImageData:msg.dataItem.imageData];
            NSRange range = [imageType rangeOfString:@"image/"];
            if (range.location != NSNotFound) {
                NSString *fileName = [NSString stringWithFormat:@"image.%@", [imageType substringFromIndex:range.location + range.length]];
                [controller addAttachmentData:msg.dataItem.imageData
                               typeIdentifier:@"OSSMSImage"
                                     filename:fileName];
            }
        }
        
        [[UIApplication sharedApplication].delegate.window.topMostViewController presentViewController:controller animated:YES completion:nil];
    }
}

@end