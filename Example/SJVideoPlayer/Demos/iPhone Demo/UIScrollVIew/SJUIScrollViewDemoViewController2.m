//
//  SJUIScrollViewDemoViewController1.m
//  SJVideoPlayer_Example
//
//  Created by BlueDancer on 2020/7/8.
//  Copyright © 2020 changsanjiang. All rights reserved.
//

#import "SJUIScrollViewDemoViewController2.h"
#import <Masonry/Masonry.h>
#import "SJPlayerSuperview.h"
#import <SJVideoPlayer/SJVideoPlayer.h>
#import "SJSourceURLs.h"


@interface SJPlayModel (SJUIScrollViewDemoAdded)
+ (instancetype)playModelWithScrollView:(UIScrollView *__weak)scrollView superviewTag:(NSInteger)superviewTag;
@end

@implementation SJPlayModel (SJUIScrollViewDemoAdded)
+ (instancetype)playModelWithScrollView:(UIScrollView *__weak)scrollView superviewTag:(NSInteger)superviewTag {
    SJPlayModel *model = [SJPlayModel playModelWithScrollView:scrollView];
    model.superviewTag = superviewTag;
    return model;
}
@end


@interface SJUIScrollViewDemoViewController2 ()
@property (nonatomic, strong) UIScrollView *scrollView;
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
    
    _scrollView = [UIScrollView.alloc initWithFrame:CGRectZero];
    _scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height * 3);
    _scrollView.backgroundColor = UIColor.purpleColor;
    [self.view addSubview:_scrollView];
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    SJPlayerSuperview *playerSuperview = [SJPlayerSuperview.alloc initWithFrame:CGRectZero];
    playerSuperview.backgroundColor = UIColor.redColor;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap0)];
    [playerSuperview addGestureRecognizer:tap];
    [_scrollView addSubview:playerSuperview];
    playerSuperview.tag = 100;
    [playerSuperview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(100);
        make.left.offset(0);
        make.width.offset(self.view.bounds.size.width);
        make.height.equalTo(playerSuperview.mas_width).multipliedBy(9/16.0);
    }];
    
    SJPlayerSuperview *playerSuperview1 = [SJPlayerSuperview.alloc initWithFrame:CGRectZero];
    playerSuperview1.backgroundColor = UIColor.greenColor;
    playerSuperview1.tag = 101;
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap1)];
    [playerSuperview1 addGestureRecognizer:tap1];
    [_scrollView addSubview:playerSuperview1];
    [playerSuperview1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(300);
        make.left.offset(0);
        make.width.offset(self.view.bounds.size.width);
        make.height.equalTo(playerSuperview1.mas_width).multipliedBy(9/16.0);
    }];
    
    SJPlayerSuperview *playerSuperview2 = [SJPlayerSuperview.alloc initWithFrame:CGRectZero];
    playerSuperview2.tag = 102;
    playerSuperview2.backgroundColor = UIColor.blueColor;
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap2)];
    [playerSuperview2 addGestureRecognizer:tap2];
    [_scrollView addSubview:playerSuperview2];
    [playerSuperview2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(500);
        make.left.offset(0);
        make.width.offset(self.view.bounds.size.width);
        make.height.equalTo(playerSuperview2.mas_width).multipliedBy(9/16.0);
    }];
    
    SJPlayerSuperview *playerSuperview3 = [SJPlayerSuperview.alloc initWithFrame:CGRectZero];
    playerSuperview3.tag = 103;
    playerSuperview3.backgroundColor = UIColor.blackColor;
    UITapGestureRecognizer *tap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap3)];
    [playerSuperview3 addGestureRecognizer:tap3];
    [_scrollView addSubview:playerSuperview3];
    [playerSuperview3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(900);
        make.left.offset(0);
        make.width.offset(self.view.bounds.size.width);
        make.height.equalTo(playerSuperview3.mas_width).multipliedBy(9/16.0);
    }];
}

- (void)tap0{
    _player.URLAsset = [SJVideoPlayerURLAsset.alloc initWithURL:SourceURL0 playModel:[SJPlayModel playModelWithScrollView:_scrollView superviewTag:100]];
    [_player play];
}

- (void)tap1 {
    _player.URLAsset = [SJVideoPlayerURLAsset.alloc initWithURL:SourceURL1 playModel:[SJPlayModel playModelWithScrollView:_scrollView superviewTag:101]];
    [_player play];
}

- (void)tap2 {
    _player.URLAsset = [SJVideoPlayerURLAsset.alloc initWithURL:SourceURL2 playModel:[SJPlayModel playModelWithScrollView:_scrollView superviewTag:102]];
    [_player play];
}

- (void)tap3 {
    _player.URLAsset = [SJVideoPlayerURLAsset.alloc initWithURL:SourceURL3 playModel:[SJPlayModel playModelWithScrollView:_scrollView superviewTag:103]];
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
