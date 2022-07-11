//
//  SJSubtitlesTestViewController.m
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2019/11/8.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import "SJSubtitlesTestViewController.h"
#import <SJBaseVideoPlayer/SJVideoPlayerURLAsset+SJSubtitlesAdd.h>
#import "SJVideoPlayer.h"
#import "Masonry.h"
#import "SJSourceURLs.h"
#import <SJUIKit/NSAttributedString+SJMake.h>

NS_ASSUME_NONNULL_BEGIN
@interface SJSubtitlesTestViewController ()
@property (nonatomic, strong) SJVideoPlayer *player;
@end

@implementation SJSubtitlesTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViews];
    [self _test];
}

- (void)_test {
    NSArray<NSString *> *testtitles = @[@"悲哀化身-内蒙专区", @"车迟国@最终幻想-剑侠风骨车迟国", @"老虎222-天竺国", @"今朝醉-云中殿今朝醉-云中殿今朝醉-云中殿", @"杀手阿七-五明宫杀手阿七-五明宫", @"浅墨淋雨桥-剑胆琴心"];
    
    SJVideoPlayerURLAsset *asset = [SJVideoPlayerURLAsset.alloc initWithURL:VideoURL_Level4];
    NSMutableArray<SJSubtitleItem *> *subtitles = NSMutableArray.array;
    NSTimeInterval start = 0;    // 字幕开始显示的时间
    NSTimeInterval duration = 3; // 字幕持续的时间
    for ( int i = 0 ; i < 20 ; ++ i ) {
        NSAttributedString *content = [NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
            make.font([UIFont boldSystemFontOfSize:17]);
            make.append(testtitles[arc4random() % testtitles.count]);
            make.textColor(UIColor.whiteColor);
            make.stroke(^(id<SJUTStroke>  _Nonnull make) {
                make.width = -1;
                make.color = UIColor.blackColor;
            });
        }];
        [subtitles addObject:[SJSubtitleItem.alloc initWithContent:content range:SJMakeTimeRange(start, duration)]];
        start += duration + 2;
    }
    asset.subtitles = subtitles;

//    self.player.subtitlePopupController.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
//    self.player.subtitlePopupController.view.layer.cornerRadius = 5;
//    self.player.subtitlePopupController.contentInsets = UIEdgeInsetsMake(12, 22, 12, 22);
    self.player.URLAsset = asset;
}

- (void)_setupViews {
    self.view.backgroundColor = UIColor.whiteColor;
    _player = SJVideoPlayer.player;
    [self.view addSubview:_player.view];
    [_player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        } else {
            make.top.offset(20);
        }
        make.left.right.offset(0);
        make.height.equalTo(self.view.mas_width).multipliedBy(9/16.0);
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.player vc_viewDidAppear];
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

@interface SJSubtitlesTestViewController (RouteHandler)<SJRouteHandler>

@end

@implementation SJSubtitlesTestViewController (RouteHandler)
+ (NSString *)routePath {
    return @"subtitles/demo";
}

+ (void)handleRequest:(SJRouteRequest *)request topViewController:(UIViewController *)topViewController completionHandler:(SJCompletionHandler)completionHandler {
    [topViewController.navigationController pushViewController:self.new animated:YES];
}
@end
