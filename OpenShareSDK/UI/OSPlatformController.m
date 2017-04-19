//
//  OSPlatformController.m
//  OpenShare_2
//
//  Created by jia on 16/5/3.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import "OSPlatformController.h"
#import "OpenShare.h"

static NSString *const kCellIdentifier = @"UICollectionViewCell";
static NSInteger const kContentBtnTag = 1024;
static CGFloat const kAnimDuration = 0.2f;

@interface OSPlatformController () <UICollectionViewDataSource, UICollectionViewDelegate
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
, CAAnimationDelegate
#endif
>

@property (nonatomic, strong) NSMutableArray *platforms;
@end

@implementation OSPlatformController {
@private
    UICollectionView *_collectionView;
    NSDictionary *_platformConfig;
    UIView *_containerView;
    UIView *_grayTouchView;
    UIButton *_cancelBtn;
}

- (NSBundle *)openShareBundle
{
    static dispatch_once_t onceToken;
    static NSBundle *bundle = nil;
    dispatch_once(&onceToken, ^{
        NSURL *url = [[NSBundle bundleForClass:self.class] URLForResource:@"OpenShareResources" withExtension:@"bundle"];
        if (nil != url) {
            bundle = [NSBundle bundleWithURL:url];
        }
    });
    return bundle;
}

- (UIImage *)snsImageNamed:(NSString *)name
{
    NSString *path = [NSString stringWithFormat:@"OpenShareResources.bundle/%@", name];
    return [UIImage imageNamed:path];
}

- (NSDictionary *)platformConfig
{
    if (nil == _platformConfig) {
        _platformConfig = @{@(kOSPlatformQQ): @{@"name": @"os.platform.qq",
                                                @"image": @"os_qq_icon.png"},
                            @(kOSPlatformQQZone): @{@"name": @"os.platform.qzone",
                                                    @"image": @"os_qzone_icon.png"},
                            @(kOSPlatformWXSession): @{@"name": @"os.platform.wxsession",
                                                       @"image": @"os_wechat_icon.png"},
                            @(kOSPlatformWXTimeLine): @{@"name": @"os.platform.wxtimeline",
                                                        @"image": @"os_wechat_timeline_icon.png"},
                            @(kOSPlatformSina): @{@"name": @"os.platform.sina",
                                                  @"image": @"os_sina_icon.png"},
                            @(kOSPlatformEmail): @{@"name": @"os.platform.email",
                                                   @"image": @"os_email_icon.png"},
                            @(kOSPlatformSms): @{@"name": @"os.platform.sms",
                                                 @"image": @"os_sms_icon.png"},
                            @(kOSPlatformCopyUrl): @{@"name": @"os.platform.copyurl",
                                                     @"image": @"os_copy_url"},
                            @(kOSPlatformFacebook): @{@"name": @"os.platform.facebook",
                                                     @"image": @"os_fb_icon"},
                            @(kOSPlatformTwitter): @{@"name": @"os.platform.twitter",
                                                     @"image": @"os_tw_icon"}};
    }
    return _platformConfig;
}

- (instancetype)initWithPlatformCodes:(NSArray<NSNumber/*OSPlatformCode*/ *> *)codes
{
    if (self = [super init]) {
        if (nil == _platforms) {
            _platforms = NSMutableArray.array;
        }
        
        for (NSNumber *code in codes) {
            OSPlatformItem *platform = [[OSPlatformItem alloc] init];
            platform.displayName = NSLocalizedStringFromTableInBundle(self.platformConfig[code][@"name"], nil, self.openShareBundle, nil);
            platform.displayIcon = [self snsImageNamed:self.platformConfig[code][@"image"]];
            platform.code = code.integerValue;
            [_platforms addObject:platform];
        }
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _grayTouchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _grayTouchView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    _grayTouchView.hidden = YES;
    _grayTouchView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDismiss)];
    [_grayTouchView addGestureRecognizer:tapGes];
    [self.view addSubview:_grayTouchView];

    CGFloat spacing = 2.0f;
    CGFloat itemWidth = [UIScreen mainScreen].bounds.size.width > 320.0f ? 90.0f : 77.0f;
    CGFloat cancelBtnHeight = 49.0f;
    CGFloat separatorLineHeight = [UIView pointWithPixel:1.0f];
    
    CGFloat maxNumberOfItemsInRow = floor([UIScreen mainScreen].bounds.size.width / itemWidth);
    NSInteger row = ceil(_platforms.count / maxNumberOfItemsInRow);
    CGFloat collectionViewHeight = row * itemWidth + (row + 1) * spacing;
    
    CGRect rect = self.view.frame;
    rect.size.height = collectionViewHeight + separatorLineHeight + cancelBtnHeight;
    rect.origin.y = self.view.bounds.size.height - rect.size.height;
    
    _containerView = [[UIView alloc] initWithFrame:rect];
    [self.view addSubview:_containerView];

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumLineSpacing = spacing;
    layout.minimumInteritemSpacing = spacing;
    layout.sectionInset = UIEdgeInsetsMake(spacing, spacing, spacing, spacing);
    layout.itemSize = (CGSize){.width = itemWidth, .height = itemWidth};
    
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _containerView.frame.size.width, collectionViewHeight) collectionViewLayout:layout];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.backgroundColor = [UIColor whiteColor];
    [_collectionView registerClass:UICollectionViewCell.class forCellWithReuseIdentifier:kCellIdentifier];
    _collectionView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_containerView addSubview:_collectionView];
    
    UIView *separatorLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(_collectionView.frame), self.view.bounds.size.width, separatorLineHeight)];
    separatorLine.backgroundColor = RGBHex(0xdcdcdc);
    [_containerView addSubview:separatorLine];
    
    _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _cancelBtn.backgroundColor = [UIColor whiteColor];
    [_cancelBtn setTitleColor:RGBHex(0x333333) forState:UIControlStateNormal];

    NSString *cancelTitle = NSLocalizedStringFromTableInBundle(@"public.button.cancel", nil, self.openShareBundle, nil);
    [_cancelBtn setTitle:cancelTitle forState:UIControlStateNormal];
    _cancelBtn.frame = CGRectMake(0.0f, CGRectGetMaxY(separatorLine.frame), self.view.bounds.size.width, cancelBtnHeight);
    _cancelBtn.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_cancelBtn addTarget:self action:@selector(tapDismiss) forControlEvents:UIControlEventTouchUpInside];
    [_containerView addSubview:_cancelBtn];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self show];
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _platforms.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];

    UIButton *contentBtn = [cell.contentView viewWithTag:kContentBtnTag];
    if (nil == contentBtn) {
        contentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        contentBtn.frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height);
        contentBtn.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        contentBtn.tag = 1024;
        contentBtn.userInteractionEnabled = NO;
        contentBtn.layoutStyle = kTCButtonLayoutStyleImageTopTitleBottom;
        contentBtn.paddingBetweenTitleAndImage = 5.0f;
        contentBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        contentBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        [contentBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [cell.contentView addSubview:contentBtn];
    }
    
    OSPlatformItem *platform = _platforms[indexPath.item];
    [contentBtn setTitle:platform.displayName forState:UIControlStateNormal];
    [contentBtn setImage:platform.displayIcon forState:UIControlStateNormal];
    
    return cell;
}


#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    __weak typeof(self) wSelf = self;
    [self dismiss:^{
        if (nil != wSelf.delegate && [wSelf.delegate respondsToSelector:@selector(OSPlatformController:didSelectPlatformItem:)]) {
            [wSelf.delegate OSPlatformController:wSelf didSelectPlatformItem:wSelf.platforms[indexPath.item]];
        }
    }];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tapDismiss
{
    __weak typeof(self) wSelf = self;
    [self dismiss:^{
        if (nil != wSelf.delegate && [wSelf.delegate respondsToSelector:@selector(OSPlatformControllerWillDismiss:)]) {
            [wSelf.delegate OSPlatformControllerWillDismiss:wSelf];
        }
    }];
}

- (void)show
{
    CATransition *animation = [CATransition animation];
    animation.duration = kAnimDuration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.type = kCATransitionMoveIn;
    animation.subtype = kCATransitionFromTop;
    animation.removedOnCompletion = YES;
    [_containerView.layer addAnimation:animation forKey:nil];
    
    CATransition *hiddenAnim = [CATransition animation];
    hiddenAnim.type = kCATransitionReveal;
    hiddenAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    hiddenAnim.duration = kAnimDuration;
    hiddenAnim.removedOnCompletion = YES;
    [_grayTouchView.layer addAnimation:hiddenAnim forKey:nil];
    _grayTouchView.hidden = NO;
}

- (void)dismiss:(void(^)(void))completion
{
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = kAnimDuration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.type = kCATransitionReveal;
    animation.subtype = kCATransitionFromBottom;
    animation.removedOnCompletion = YES;
    [animation setValue:completion forKey:@"finishBlock"];
    [_containerView.layer addAnimation:animation forKey:nil];
    _containerView.hidden = YES;
    
    CATransition *hiddenAnim = [CATransition animation];
    hiddenAnim.type = kCATransitionFade;
    hiddenAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    hiddenAnim.duration = kAnimDuration;
    hiddenAnim.removedOnCompletion = YES;
    [_grayTouchView.layer addAnimation:hiddenAnim forKey:nil];
    _grayTouchView.hidden = YES;
}


#pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    void(^completion)(void) = [anim valueForKey:@"finishBlock"];
    if (nil != completion) {
        completion();
    }
}

@end

@implementation OSPlatformItem

@end
