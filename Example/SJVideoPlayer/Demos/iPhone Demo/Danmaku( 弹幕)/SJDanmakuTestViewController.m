//
//  SJDanmakuTestViewController.m
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2019/11/14.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import "SJDanmakuTestViewController.h"
#import <SJBaseVideoPlayer/SJVideoPlayerURLAsset+SJSubtitlesAdd.h>
#import "SJVideoPlayer.h"
#import "Masonry.h"
#import "SJSourceURLs.h"
#import <SJUIKit/NSAttributedString+SJMake.h>

#import <SJBaseVideoPlayer/SJDanmakuPopupController.h>
#import <SJBaseVideoPlayer/SJDanmakuItem.h>

NS_ASSUME_NONNULL_BEGIN
@interface SJDanmakuTestViewController ()<SJDanmakuTrackConfigurationDelegate>
@property (nonatomic, strong) SJVideoPlayer *player;
@end

@implementation SJDanmakuTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViews];
    
    SJDanmakuPopupController *controller = _player.danmakuPopupController;
    controller.trackConfiguration.delegate = self;
    controller.view.clipsToBounds = YES;
}

#pragma mark - SJDanmakuTrackConfigurationDelegate

/// 配置移动速率, 这里设置了让偶数行的速率慢一点
- (CGFloat)trackConfiguration:(SJDanmakuTrackConfiguration *)trackConfiguration rateForTrackAtIndex:(NSInteger)index {
    return index % 2 == 0 ? 1 : 0.9;
}

#pragma mark - Test

- (IBAction)test_pauseOrResume:(UIButton *)sender {
    self.player.danmakuPopupController.isPaused ? [self.player.danmakuPopupController resume] : [self.player.danmakuPopupController pause];
    [sender setTitle:self.player.danmakuPopupController.isPaused ? @"Resume" : @"Pause" forState:UIControlStateNormal];
}

- (IBAction)test_send1:(id)sender {
    [self _test:1];
}

- (IBAction)test_send100:(id)sender {
    [self _test:100];
}

- (IBAction)test_rate:(UISlider *)sender {
    SJDanmakuPopupController *controller = (id)_player.danmakuPopupController;
    if ( controller.trackConfiguration.delegate == self ) {
        // 取消使用代理设置速率
        controller.trackConfiguration.delegate = nil;
        
        [_player.textPopupController show:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
            make.append(@"使用代理设置速率已被取消, 已改为手动设置!");
            make.textColor(UIColor.whiteColor);
        }] duration:4];
    }
    
    controller.trackConfiguration.rate = sender.value;
}

- (IBAction)test_changeBounds1:(id)sender {
    CGRect frame = _player.view.frame;
    frame.origin.x += 20;
    frame.origin.y += 20;
    frame.size.width -= 40;
    frame.size.height -= 40;
    _player.view.frame = frame;
}

- (IBAction)test_changeBounds2:(id)sender {
    CGRect frame = _player.view.frame;
    frame.origin.x -= 20;
    frame.origin.y -= 20;
    frame.size.width += 40;
    frame.size.height += 40;
    _player.view.frame = frame;
}

- (IBAction)test_changeLines:(id)sender {
    _player.danmakuPopupController.numberOfTracks = arc4random() % 5 + 1;
}

- (void)_test:(NSInteger)count {
    NSArray<NSString *> *testtitles = @[@"悲哀化身-内蒙专区", @"车迟国@最终幻想-剑侠风骨车迟国", @"老虎222-天竺国", @"今朝醉-云中殿今朝醉-云中殿今朝醉-云中殿", @"杀手阿七-五明宫杀手阿七-五明宫", @"浅墨淋雨桥-剑胆琴心"];
    
    for ( int i = 0 ; i < count ; ++ i ) {
        SJDanmakuItem *item = [SJDanmakuItem.alloc initWithContent:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
            make.append(testtitles[arc4random() % testtitles.count]);
            make.font([UIFont boldSystemFontOfSize:16]);
            make.textColor(UIColor.whiteColor);
            make.stroke(^(id<SJUTStroke>  _Nonnull make) {
                make.color = UIColor.blackColor;
                make.width = -1;
            });
        }]];
        [self.player.danmakuPopupController enqueue:item];
    }
}

- (void)_setupViews {
    self.view.backgroundColor = UIColor.blackColor;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    _player = SJVideoPlayer.player;
    _player.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _player.URLAsset = [SJVideoPlayerURLAsset.alloc initWithURL:SourceURL1];
    _player.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, 375);
    _player.view.clipsToBounds = YES;
    _player.defaultEdgeControlLayer.hiddenBackButtonWhenOrientationIsPortrait = YES;
    [self.view addSubview:_player.view];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.player vc_viewDidAppear];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.player vc_viewWillDisappear];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.player vc_viewDidDisappear];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}
@end
NS_ASSUME_NONNULL_END


#import <SJRouter.h>

@interface SJDanmakuTestViewController (RouteHandler)<SJRouteHandler>

@end

@implementation SJDanmakuTestViewController (RouteHandler)
+ (NSString *)routePath {
    return @"danmaku/demo";
}

+ (void)handleRequest:(SJRouteRequest *)request topViewController:(UIViewController *)topViewController completionHandler:(SJCompletionHandler)completionHandler {
    [topViewController.navigationController pushViewController:self.new animated:YES];
}
@end
