//
//  ViewController.m
//  OpenShareDemo
//
//  Created by jia on 16/5/30.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import "ViewController.h"
#import "OpenShareManager.h"
#import "OpenShareHeader.h"

@interface ViewController ()

@end

@implementation ViewController
{
    @private
    OSMessage *_message;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    OSDataItem *dataItem = [[OSDataItem alloc] init];
    dataItem.title = @"testTitle";
    dataItem.content = @"testDes";
    dataItem.link = [NSURL URLWithString:@"http://sina.cn?a=1"];
    //    dataItem.imageUrl = [NSURL URLWithString:@"http://i.k1982.com/design_img/201109/201109011617318631.jpg"];
    
    NSString *file = [[NSBundle mainBundle] pathForResource:@"demo" ofType:@"jpeg"];
    dataItem.imageData = [[NSData alloc] initWithContentsOfFile:file];
    NSString *thumbnail = [[NSBundle mainBundle] pathForResource:@"demo" ofType:@"jpeg"];
    dataItem.thumbnailData = [[NSData alloc] initWithContentsOfFile:thumbnail];
    dataItem.emailSubject = @"emailSub";
    dataItem.emailBody = @"emailBody";
    //    dataItem.toRecipients = @[@"123@126.com"];
    dataItem.mediaDataUrl = @"http://7qn9mz.com1.z0.glb.clouddn.com/0002.mp3";
    
//    [dataItem setValue:@"wx" forKey:PropertySTR(title) forPlatform:kOpenSharePlatformWXSession];
    
    _message = [[OSMessage alloc] init];
    _message.dataItem = dataItem;
    _message.multimediaType = OSMultimediaTypeNews;
    
    UIButton *invokeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    invokeBtn.frame = CGRectMake(0, 100, self.view.frame.size.width - 40, 60);
    invokeBtn.center = CGPointMake(self.view.center.x, invokeBtn.center.y);
    invokeBtn.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.5];
    [invokeBtn setTitle:@"分享" forState:UIControlStateNormal];
    [invokeBtn addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:invokeBtn];

}

- (void)share
{
    [[OpenShareManager defaultManager] shareMsg:_message platformCodes:@[@(kOSPlatformTwitter), @(kOSPlatformFacebook), @(kOSPlatformQQ)] completion:^(OSMessage *message, OSShareState state, NSError *error) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
