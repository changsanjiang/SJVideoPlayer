//
//  SJBarrageTestViewController.m
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2019/11/14.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import "SJBarrageTestViewController.h"
#import <SJBaseVideoPlayer/SJVideoPlayerURLAsset+SJSubtitlesAdd.h>
#import "SJVideoPlayer.h"
#import "Masonry.h"
#import "SJSourceURLs.h"
#import <SJUIKit/NSAttributedString+SJMake.h>

#import <SJBaseVideoPlayer/SJBarrageQueueController.h>
#import <SJBaseVideoPlayer/SJBarrageItem.h>

NS_ASSUME_NONNULL_BEGIN
@interface SJBarrageTestViewController ()<SJBarrageLineConfigurationDelegate>
@property (nonatomic, strong) SJVideoPlayer *player;
@end

@implementation SJBarrageTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViews];
    
    SJBarrageQueueController *controller = _player.barrageQueueController;
    controller.configuration.delegate = self;
    controller.view.clipsToBounds = YES;
}

#pragma mark - SJBarrageLineConfigurationDelegate

/// 配置移动速率, 这里设置了让偶数行的速率慢一点
- (CGFloat)barrageLineConfiguration:(SJBarrageLineConfiguration *)configuration rateForLineAtIndex:(NSInteger)index {
    return index % 2 == 0 ? 1 : 0.9;
}

#pragma mark - Test

- (IBAction)test_pauseOrResume:(UIButton *)sender {
    self.player.barrageQueueController.isPaused ? [self.player.barrageQueueController resume] : [self.player.barrageQueueController pause];
    [sender setTitle:self.player.barrageQueueController.isPaused ? @"Resume" : @"Pause" forState:UIControlStateNormal];
}

- (IBAction)test_send1:(id)sender {
    [self _test:1];
}

- (IBAction)test_send100:(id)sender {
    [self _test:100];
}

- (IBAction)test_rate:(UISlider *)sender {
    SJBarrageQueueController *controller = (id)_player.barrageQueueController;
    if ( controller.configuration.delegate == self ) {
        // 取消使用代理设置速率
        controller.configuration.delegate = nil;
        
        [_player.prompt show:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
            make.append(@"使用代理设置速率已被取消, 已改为手动设置!");
            make.textColor(UIColor.whiteColor);
        }] duration:4];
    }
    
    controller.configuration.rate = sender.value;
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
    _player.barrageQueueController.numberOfLines = arc4random() % 5 + 1;
}

- (void)_test:(NSInteger)count {
    NSArray<NSString *> *testtitles = @[@"悲哀化身-内蒙专区", @"车迟国@最终幻想-剑侠风骨车迟国", @"老虎222-天竺国", @"今朝醉-云中殿今朝醉-云中殿今朝醉-云中殿", @"杀手阿七-五明宫杀手阿七-五明宫", @"浅墨淋雨桥-剑胆琴心"];
    
    for ( int i = 0 ; i < count ; ++ i ) {
        SJBarrageItem *item = [SJBarrageItem.alloc initWithContent:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
            make.append(testtitles[arc4random() % testtitles.count]);
            make.font([UIFont boldSystemFontOfSize:16]);
            make.textColor(UIColor.whiteColor);
            make.stroke(^(id<SJUTStroke>  _Nonnull make) {
                make.color = UIColor.blackColor;
                make.width = -1;
            });
        }]];
        [self.player.barrageQueueController enqueue:item];
    }
}

- (void)_setupViews {
    self.view.backgroundColor = UIColor.blackColor;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    _player = SJVideoPlayer.player;
    _player.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _player.URLAsset = [SJVideoPlayerURLAsset.alloc initWithURL:SourceURL1];
    _player.view.frame = CGRectMake(0, 0, 375, 375);
    _player.view.clipsToBounds = YES;
    [self.view addSubview:_player.view];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.player vc_viewDidAppear];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.player vc_viewWillDisappear];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
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

@interface SJBarrageTestViewController (RouteHandler)<SJRouteHandler>

@end

@implementation SJBarrageTestViewController (RouteHandler)
+ (NSString *)routePath {
    return @"barrage/demo";
}

+ (void)handleRequest:(SJRouteRequest *)request topViewController:(UIViewController *)topViewController completionHandler:(SJCompletionHandler)completionHandler {
    [topViewController.navigationController pushViewController:self.new animated:YES];
}
@end
