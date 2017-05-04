//
//  OpenShare+Mail.m
//  OpenShare_2
//
//  Created by jia on 16/5/3.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import "OpenShare+Mail.h"
#import "OpenShare+Helper.h"
#import "UIWindow+TCHelper.h"
#import "NSData+MIMEType.h"

@implementation OpenShare (Mail)

+ (void)shareToMail:(OSMessage *)msg delegate:(id<MFMailComposeViewControllerDelegate>)delegate
{
    if (MFMailComposeViewController.canSendMail) {
        msg.dataItem.platformCode = kOSPlatformEmail;
        
        MFMailComposeViewController *mailComposeCtrler = [[MFMailComposeViewController alloc] init];
        mailComposeCtrler.mailComposeDelegate = delegate;
        [mailComposeCtrler setToRecipients:msg.dataItem.toRecipients];
        [mailComposeCtrler setCcRecipients:msg.dataItem.ccRecipients];
        mailComposeCtrler.subject = msg.dataItem.emailSubject;
        [mailComposeCtrler setMessageBody:msg.dataItem.emailBody isHTML:YES];
        
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
            
            [mailComposeCtrler addAttachmentData:msg.dataItem.attachment mimeType:mimeType fileName:fileName];
        }
        
        [[UIApplication sharedApplication].delegate.window.topMostViewController presentViewController:mailComposeCtrler animated:YES completion:nil];
        
    } else {
        msg.dataItem.platformCode = kOSPlatformEmail;
        
        NSMutableString *email = [[NSMutableString alloc] initWithString:@"mailto:"];
        if (msg.dataItem.toRecipients.count > 0) {
            [email appendFormat:@"%@?", [msg.dataItem.toRecipients componentsJoinedByString:@","]];
        } else {
            [email appendString:@"?"];
        }
        
        if (msg.dataItem.ccRecipients.count > 0) {
            [email appendFormat:@"cc=%@", [msg.dataItem.ccRecipients componentsJoinedByString:@","]];
        }
        
        if (nil != msg.dataItem.emailSubject) {
            [email appendString:[NSString stringWithFormat:@"&subject=%@", msg.dataItem.emailSubject]];
        }
        if (nil != msg.dataItem.emailBody) {
            [email appendString:[NSString stringWithFormat:@"&body=%@", msg.dataItem.emailBody]];
        }
        
        NSString *url = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [UIApplication.sharedApplication openURL:[NSURL URLWithString:url] options:@{} completionHandler:nil];
    }
}

@end
