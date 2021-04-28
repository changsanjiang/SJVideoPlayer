//
//  SJUIScrollViewDemoViewController1.m
//  SJVideoPlayer_Example
//
//  Created by BlueDancer on 2020/7/8.
//  Copyright © 2020 changsanjiang. All rights reserved.
//

#import "SJUIScrollViewDemoViewController2.h"
#import <Masonry/Masonry.h>
#import <SJVideoPlayer/SJVideoPlayer.h>
#import "SJSourceURLs.h"

 
@interface SJDemoScrollView2 : UIScrollView
@property (nonatomic, strong, readonly) UIView *playerSuperview1;
@property (nonatomic, strong, readonly) UIView *playerSuperview2;
@end

@implementation SJDemoScrollView2
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( self ) {
        _playerSuperview1 = [UIView.alloc initWithFrame:CGRectZero];
        _playerSuperview1.backgroundColor = UIColor.redColor;
        [self addSubview:_playerSuperview1];
        [_playerSuperview1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.offset(100);
            make.centerX.offset(0);
            make.width.offset(UIScreen.mainScreen.bounds.size.width);
            make.height.equalTo(_playerSuperview1.mas_width).multipliedBy(9/16.0);
        }];
        
        _playerSuperview2 = [UIView.alloc initWithFrame:CGRectZero];
        _playerSuperview2.backgroundColor = UIColor.redColor;
        [self addSubview:_playerSuperview2];
        [_playerSuperview2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.playerSuperview1.mas_bottom).offset(20);
            make.size.equalTo(self.playerSuperview1);
            make.centerX.equalTo(self.playerSuperview1);
        }];
    }
    return self;
}
@end

@interface SJUIScrollViewDemoViewController2 ()
@property (nonatomic, strong) SJDemoScrollView2 *scrollView;
@property (nonatomic, strong) SJVideoPlayer *player;
@end

@implementation SJUIScrollViewDemoViewController2
- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViews];
    
    _player = SJVideoPlayer.player;
}

- (void)_setupViews {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    _scrollView = [SJDemoScrollView2.alloc initWithFrame:CGRectZero];
    _scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height * 3);
    _scrollView.backgroundColor = UIColor.purpleColor;
    [self.view addSubview:_scrollView];
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    UITapGestureRecognizer *tap1 = [UITapGestureRecognizer.alloc initWithTarget:self action:@selector(tap1)];
    [_scrollView.playerSuperview1 addGestureRecognizer:tap1];
    
    UITapGestureRecognizer *tap2 = [UITapGestureRecognizer.alloc initWithTarget:self action:@selector(tap2)];
    [_scrollView.playerSuperview2 addGestureRecognizer:tap2];
}

- (void)tap1 {
    _player.URLAsset = [SJVideoPlayerURLAsset.alloc initWithURL:SourceURL0 playModel:[SJPlayModel playModelWithScrollView:_scrollView superviewSelector:@selector(playerSuperview1)]];
    [_player play];
}

- (void)tap2 {
    _player.URLAsset = [SJVideoPlayerURLAsset.alloc initWithURL:SourceURL1 playModel:[SJPlayModel playModelWithScrollView:_scrollView superviewSelector:@selector(playerSuperview2)]];
    [_player play];
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
