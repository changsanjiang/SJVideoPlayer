//
//  SJUIScrollViewDemoViewController1.m
//  SJVideoPlayer_Example
//
//  Created by BlueDancer on 2020/7/8.
//  Copyright © 2020 changsanjiang. All rights reserved.
//

#import "SJUIScrollViewDemoViewController1.h"
#import <Masonry/Masonry.h>
#import <SJVideoPlayer/SJVideoPlayer.h>
#import "SJSourceURLs.h"

@interface SJDemoScrollView1 : UIScrollView
@property (nonatomic, strong, readonly) UIView *playerSuperview;
@end

@implementation SJDemoScrollView1
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( self ) {
        _playerSuperview = [UIView.alloc initWithFrame:CGRectZero];
        _playerSuperview.backgroundColor = UIColor.redColor;
        [self addSubview:_playerSuperview];
        [_playerSuperview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.offset(100);
            make.centerX.offset(0);
            make.width.offset(UIScreen.mainScreen.bounds.size.width);
            make.height.equalTo(_playerSuperview.mas_width).multipliedBy(9/16.0);
        }];
    }
    return self;
}
@end

@interface SJUIScrollViewDemoViewController1 ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) SJVideoPlayer *player;
@end

@implementation SJUIScrollViewDemoViewController1

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViews];
    
    _player = SJVideoPlayer.player;
    SJPlayModel *model = [SJPlayModel playModelWithScrollView:_scrollView superviewSelector:NSSelectorFromString(@"playerSuperview")];
    _player.URLAsset = [SJVideoPlayerURLAsset.alloc initWithURL:SourceURL0 playModel:model];
    [_player play];
}

- (void)_setupViews {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    _scrollView = [SJDemoScrollView1.alloc initWithFrame:CGRectZero];
    _scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height * 3);
    _scrollView.backgroundColor = UIColor.purpleColor;
    [self.view addSubview:_scrollView];
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
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
