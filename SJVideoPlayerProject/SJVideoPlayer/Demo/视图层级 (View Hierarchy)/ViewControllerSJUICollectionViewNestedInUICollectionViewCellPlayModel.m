//
//  ViewControllerSJUICollectionViewNestedInUICollectionViewCellPlayModel.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2018/9/30.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import "ViewControllerSJUICollectionViewNestedInUICollectionViewCellPlayModel.h"
#import <Masonry/Masonry.h>
#import <SJRouter/SJRouter.h>
#import "SJVideoPlayer.h"
#import "CollectionViewCellHasCollectionView.h"

@interface ViewControllerSJUICollectionViewNestedInUICollectionViewCellPlayModel ()<SJRouteHandler, UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) SJVideoPlayer *player;
@end

@implementation ViewControllerSJUICollectionViewNestedInUICollectionViewCellPlayModel

+ (NSString *)routePath {
    return @"collectionView/cell/collectionView/cell/play";
}

+ (void)handleRequestWithParameters:(SJParameters)parameters topViewController:(UIViewController *)topViewController completionHandler:(SJCompletionHandler)completionHandler {
    [topViewController.navigationController pushViewController:[self new] animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.itemSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.width * 9 / 16.0 + 8);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [CollectionViewCellHasCollectionView registerWithCollectionView:_collectionView];
    [self.view addSubview:_collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    // Do any additional setup after loading the view.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 99;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [CollectionViewCellHasCollectionView cellWithCollectionView:collectionView indexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(CollectionViewCellHasCollectionView *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) _self = self;
    cell.view.clickedPlayButtonExeBlock = ^(SJHasCollectionView * _Nonnull containerView, SJPlayView * _Nonnull view, NSIndexPath * _Nonnull playViewIndexPath) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.player stopAndFadeOut];
        
        // create new player
        self.player = [SJVideoPlayer player];
#ifdef SJMAC
        self.player.disablePromptWhenNetworkStatusChanges = YES;
#endif
        [view.coverImageView addSubview:self.player.view];
        [self.player.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.offset(0);
        }];
        
        self.player.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"play" withExtension:@"mp4"] playModel:[SJPlayModel UICollectionViewNestedInUICollectionViewCellPlayModelWithPlayerSuperviewTag:view.coverImageView.tag atIndexPath:playViewIndexPath collectionViewTag:containerView.collectionView.tag collectionViewAtIndexPath:indexPath rootCollectionView:self.collectionView]];
        self.player.URLAsset.title = @"Test Title";
        self.player.URLAsset.alwaysShowTitle = YES;
        
    };
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
@end
