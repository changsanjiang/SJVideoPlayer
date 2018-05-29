//
//  PlayerViewController.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/11/29.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "PlayerViewController.h"
#import "SJVideoPlayer.h"
#import <Masonry.h>
#import <SJUIFactory/SJUIFactory.h>
#import "SJSharedVideoPlayerHelper.h"

@interface PlayerViewController ()<SJSharedVideoPlayerHelperUseProtocol>

@property (nonatomic, strong, readonly) UIView *playerBackgroundView;
@property (nonatomic, strong, readonly) UIButton *nextVCBtn;
@property (nonatomic, strong, readonly) UIButton *otherVideoBtn;
@property (nonatomic, strong) SJVideoPlayerURLAsset *asset; // 由于这个`VC`使用的是播放器单例, 所以需要记录`asset`, 以便再次进入该控制器时, 继续播放该资源.

@end

@implementation PlayerViewController

@synthesize playerBackgroundView = _playerBackgroundView;
@synthesize nextVCBtn = _nextVCBtn;
@synthesize otherVideoBtn = _otherVideoBtn;

 #pragma mark - 生命周期函数

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _playerVCSetupViews];
    [self _playerVCAccessNetwork];
    
    // Do any additional setup after loading the view.
}

- (void)dealloc {
    NSLog(@"%d - %s", (int)__LINE__, __func__);
    [SJSharedVideoPlayerHelper sharedHelper].vc_deallocExeBlock();
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [SJSharedVideoPlayerHelper sharedHelper].vc_viewWillAppearExeBlock(self, self.asset);   // 这些代码都是固定的, 所以就抽成了一个block, 传入必要参数即可.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [SJSharedVideoPlayerHelper sharedHelper].vc_viewWillDisappearExeBlock();                // 这些代码都是固定的, 所以就抽成了一个block, 传入必要参数即可.
}

- (BOOL)prefersStatusBarHidden {
    return [SJSharedVideoPlayerHelper sharedHelper].vc_prefersStatusBarHiddenExeBlock();    // 这些代码都是固定的, 所以就抽成了一个block, 传入必要参数即可.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [SJSharedVideoPlayerHelper sharedHelper].vc_preferredStatusBarStyleExeBlock();   // 这些代码都是固定的, 所以就抽成了一个block, 传入必要参数即可.
}


#pragma mark - 网路请求

- (void)_playerVCAccessNetwork {
    // 模拟网络延时
    __weak typeof(self) _self = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        NSArray<NSURL *> *URLStrs = @[
                                      [[NSBundle mainBundle] URLForResource:@"sample" withExtension:@"mp4"],
                                      [NSURL URLWithString:@"http://video.cdn.lanwuzhe.com/usertrend/166162-1513873330.mp4"]
                                      ];
        self.asset = /* 记录资源, 以便返回该界面时, 继续播放他 */
        [[SJVideoPlayerURLAsset alloc] initWithTitle:@"DIY心情转盘 #手工##手工制作#"
                                     alwaysShowTitle:YES
                                            assetURL:URLStrs[arc4random() % 2]/*随机取一个播放的URL*/
                                           beginTime:0];
        [SJVideoPlayer sharedPlayer].URLAsset = self.asset;
    });
}


#pragma mark - UI布局

- (void)_playerVCSetupViews {
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.playerBackgroundView];
    [_playerBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(SJ_is_iPhoneX() ? 34 : 20);
        make.leading.trailing.offset(0);
        make.height.equalTo(self->_playerBackgroundView.mas_width).multipliedBy(9 / 16.0f);
    }];
    
    [self.view addSubview:self.nextVCBtn];
    [_nextVCBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
    }];
    
    [self.view addSubview:self.otherVideoBtn];
    [_otherVideoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->_nextVCBtn.mas_bottom).offset(20);
        make.centerX.equalTo(self->_nextVCBtn);
    }];
}

- (UIView *)playerBackgroundView {
    if ( _playerBackgroundView ) return _playerBackgroundView;
    _playerBackgroundView = [SJUIViewFactory viewWithBackgroundColor:[UIColor blackColor]];
    return _playerBackgroundView;
}

- (UIButton *)nextVCBtn {
    if ( _nextVCBtn ) return _nextVCBtn;
    _nextVCBtn = [SJUIButtonFactory buttonWithTitle:@"nextVC"
                                         titleColor:[UIColor blueColor]
                                               font:[UIFont boldSystemFontOfSize:17]
                                             target:self sel:@selector(pushNextVC)];
    return _nextVCBtn;
}

- (void)pushNextVC {
    [self.navigationController pushViewController:[[self class] new] animated:YES];
}
- (UIButton *)otherVideoBtn {
    if ( _otherVideoBtn ) return _otherVideoBtn;
    _otherVideoBtn = [SJUIButtonFactory buttonWithTitle:@"Other"
                                             titleColor:[UIColor blueColor]
                                                   font:[UIFont boldSystemFontOfSize:17]
                                                 target:self sel:@selector(playOtherVideo)];
    return _otherVideoBtn;
}

- (void)playOtherVideo {
    NSArray<NSURL *> *URLStrs = @[
                                  [[NSBundle mainBundle] URLForResource:@"sample" withExtension:@"mp4"],
                                  [NSURL URLWithString:@"http://video.cdn.lanwuzhe.com/usertrend/166162-1513873330.mp4"]
                                  ];
    self.asset = /* 记录资源, 以便返回该界面时, 继续播放他 */
    [[SJVideoPlayerURLAsset alloc] initWithTitle:@"[火影忍者傅人传]#火影#"
                                 alwaysShowTitle:YES
                                        assetURL:URLStrs[arc4random() % 2]/*随机取一个播放的URL*/
                                       beginTime:0];
    [SJVideoPlayer sharedPlayer].URLAsset = self.asset;
}
@end
