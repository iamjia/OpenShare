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
#import "NSData+MIMEType.h"

@implementation OpenShare (Sms)

+ (void)shareToSms:(OSMessage *)msg delegate:(id<MFMessageComposeViewControllerDelegate>)delegate
{
    if (MFMessageComposeViewController.canSendText) {
        msg.dataItem.platformCode = kOSPlatformSms;
        
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        controller.recipients = msg.dataItem.recipients;
        controller.body = msg.dataItem.msgBody;
        controller.messageComposeDelegate = delegate;
        
        if (OSMultimediaTypeImage == msg.multimediaType) {
            if (nil == msg.dataItem.attachment) {
                msg.dataItem.attachment = msg.dataItem.imageData;
            }
        }
        
        if (nil != msg.dataItem.attachment) {
            
            NSString *mimeType = msg.dataItem.attachment.MIMEType;
            NSString *fileName = msg.dataItem.attachmentFileName;
            if (fileName.length < 1) {
                
                fileName = @"file";
                
                NSString *suffix = [mimeType componentsSeparatedByString:@"/"].lastObject;
                if (suffix.length > 0) {
                    fileName = [fileName stringByAppendingFormat:@".%@", suffix];
                }
            }
            
            [controller addAttachmentData:msg.dataItem.attachment
                           typeIdentifier:mimeType
                                 filename:fileName];
        }
        
        [[UIApplication sharedApplication].delegate.window.topMostViewController presentViewController:controller animated:YES completion:nil];
    }
}

@end
