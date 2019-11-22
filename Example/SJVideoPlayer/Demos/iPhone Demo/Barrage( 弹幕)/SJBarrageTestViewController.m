//
//  SJBarrageTestViewController.m
//  SJVideoPlayer_Example
//
//  Created by BlueDancer on 2019/11/14.
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
@interface SJBarrageTestViewController ()
@property (nonatomic, strong) SJVideoPlayer *player;
@end

@implementation SJBarrageTestViewController

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViews];
}

- (IBAction)pauseOrResume:(UIButton *)sender {
    self.player.barrageQueueController.isPaused ? [self.player.barrageQueueController resume] : [self.player.barrageQueueController pause];
    [sender setTitle:self.player.barrageQueueController.isPaused ? @"Resume" : @"Pause" forState:UIControlStateNormal];
}

- (IBAction)send1:(id)sender {
    [self _test:1];
}

- (IBAction)send100:(id)sender {
    [self _test:100];
}

- (IBAction)rate:(UISlider *)sender {
    SJBarrageQueueController *controller = (id)_player.barrageQueueController;
    for ( int i = 0 ; i < 4 ; ++ i ) {
        SJBarrageLineConfiguration *config = [controller configurationAtIndex:i];
        config.rate = sender.value;
        [controller updateForConfigurations];
    }
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
    [self.view addSubview:_player.view];
    [_player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        } else {
            make.top.offset(0);
        }
        make.left.right.offset(0);
        make.height.equalTo(self.view.mas_width).multipliedBy(9/16.0);
    }];
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
