//
//  NestedCollectionViewController.m
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/9/12.
//  Copyright © 2018 SanJiang. All rights reserved.
//

#import "NestedCollectionViewController.h"
#import <Masonry.h>
#import <SJUIFactory/SJUIFactory.h>
#import "NestedCollectionViewCell.h"
#import "SJVideoPlayer.h"
#import <UIView+SJVideoPlayerAdd.h>
#import <SJFullscreenPopGesture/UIViewController+SJVideoPlayerAdd.h>

NS_ASSUME_NONNULL_BEGIN
static NSString *const NestedCollectionViewCellID = @"NestedCollectionViewCell";
@interface NestedCollectionViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong, readonly) UICollectionView *collectionView;
@property (nonatomic, strong, nullable) SJVideoPlayer *player;
@end

@implementation NestedCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.view addSubview:self.collectionView];
    
    _collectionView.contentInset = UIEdgeInsetsMake(200, 0, 0, 0);
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    
    __weak typeof(self) _self = self;
    self.sj_viewWillBeginDragging = ^(__kindof UIViewController * _Nonnull vc) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;

        self.player.disableAutoRotation = YES;
    };
    
    self.sj_viewDidEndDragging = ^(__kindof UIViewController * _Nonnull vc) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;

        self.player.disableAutoRotation = NO;
    };

    // Do any additional setup after loading the view.
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

- (BOOL)prefersStatusBarHidden {
    return [self.player vc_prefersStatusBarHidden];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [self.player vc_preferredStatusBarStyle];
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}

@synthesize collectionView = _collectionView;
- (UICollectionView *)collectionView {
    if ( _collectionView ) return _collectionView;
    _collectionView = [SJUICollectionViewFactory collectionViewWithItemSize:CGSizeMake(UIScreen.mainScreen.bounds.size.width, 200) backgroundColor:[UIColor whiteColor] scrollDirection:UICollectionViewScrollDirectionVertical minimumLineSpacing:8 minimumInteritemSpacing:0];
    [_collectionView registerClass:NSClassFromString(NestedCollectionViewCellID) forCellWithReuseIdentifier:NestedCollectionViewCellID];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    return _collectionView;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 99;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NestedCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NestedCollectionViewCellID forIndexPath:indexPath];
    __weak typeof(self) _self = self;
    cell.clickedPlayButtonExeBlock = ^(NestedCollectionViewCell * _Nonnull cell, NSIndexPath * _Nonnull clickedIndexPath, UIView * _Nonnull playerSuperView) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [self _needPlayVideoWithClickedIndexPath:clickedIndexPath playerSuperView:playerSuperView collectionViewTag:cell.collectionView.tag collectionViewAtIndexPath:indexPath];
    };
    return cell;
}

- (void)_needPlayVideoWithClickedIndexPath:(NSIndexPath *)clickedIndexPath playerSuperView:(UIView *)playerSuperView collectionViewTag:(NSInteger)collectionViewTag collectionViewAtIndexPath:(NSIndexPath *)collectionViewAtIndexPath  {
    // 全屏播放时无需重新创建播放器, 只需设置`asset`即可
    // 如果播放器不是全屏, 就重新创建一个播放器
    if ( !_player || !_player.isFullScreen ) {
        [_player stopAndFadeOut]; // 让旧的播放器淡出
        
        _player = [SJVideoPlayer player]; // 创建一个新的播放器
        _player.generatePreviewImages = YES; // 生成预览缩略图, 大概20张
        
        // fade in(淡入)
        [_player.view sj_fadeIn];
    }

    
    SJPlayModel *playModel = [SJPlayModel UICollectionViewNestedInUICollectionViewCellPlayModelWithPlayerSuperviewTag:playerSuperView.tag atIndexPath:clickedIndexPath collectionViewTag:collectionViewTag collectionViewAtIndexPath:collectionViewAtIndexPath rootCollectionView:self.collectionView];
    
    _player.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithURL:[NSURL URLWithString:@"http://v.dansewudao.com/444fccb3590845a799459f6154d2833f/fe86a70dc4b8497f828eaa19058639ba-6e51c667edc099f5b9871e93d0370245-sd.mp4"] playModel:playModel];
    [playerSuperView addSubview:_player.view]; // 将播放器添加到父视图中
    [_player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
}
@end
NS_ASSUME_NONNULL_END
