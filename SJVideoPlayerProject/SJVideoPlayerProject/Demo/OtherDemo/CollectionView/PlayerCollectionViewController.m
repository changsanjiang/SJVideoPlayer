//
//  PlayerCollectionViewController.m
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/1/11.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "PlayerCollectionViewController.h"
#import "PlayerCollectionViewCell.h"
#import <Masonry.h>
#import <SJBaseVideoPlayer/UIScrollView+ListViewAutoplaySJAdd.h>
#import "SJVideoPlayerHelper.h"

static NSString * const PlayerCollectionViewCellID = @"PlayerCollectionViewCell";

@interface PlayerCollectionViewController ()<PlayerCollectionViewCellDelegate, SJVideoPlayerHelperUseProtocol, SJPlayerAutoplayDelegate>

@property (nonatomic, strong, readonly) SJVideoPlayerHelper *videoPlayerHelper;
@property (nonatomic, strong, readonly) UIView *midLine;

@end

@implementation PlayerCollectionViewController
@synthesize midLine = _midLine;
- (instancetype)init
{
    UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
    flowLayout.itemSize = [PlayerCollectionViewCell itemSize];
    flowLayout.minimumLineSpacing = 4;
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    self = [super initWithCollectionViewLayout:flowLayout];
    if (self) { }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.title = @"CollectionView";

    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerClass:[PlayerCollectionViewCell class] forCellWithReuseIdentifier:PlayerCollectionViewCellID];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    

    SJPlayerAutoplayConfig *config = [SJPlayerAutoplayConfig configWithPlayerSuperviewTag:101 autoplayDelegate:self];
    config.animationType = SJAutoplayScrollAnimationTypeTop;
    [self.collectionView sj_enableAutoplayWithConfig:config];
    
    [self.collectionView sj_needPlayNextAsset];

    _midLine = [UIView new];
    _midLine.backgroundColor = [UIColor greenColor];
    [self.view addSubview:self.midLine];
    [self.midLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.centerY.offset(0);
        make.height.offset(2);
    }];
    
    // Do any additional setup after loading the view.
}

- (void)sj_playerNeedPlayNewAssetAtIndexPath:(NSIndexPath *)indexPath {
    [self clickedPlayOnColCell:(id)[self.collectionView cellForItemAtIndexPath:indexPath]];
}

- (void)clickedPlayOnColCell:(PlayerCollectionViewCell *)cell {
    SJVideoPlayerURLAsset *asset = [[SJVideoPlayerURLAsset alloc] initWithURL:[NSURL URLWithString:@"https://www.apple.com/105/media/us/iphone-x/2017/01df5b43-28e4-4848-bf20-490c34a926a7/films/feature/iphone-x-feature-tpl-cc-us-20170912_1280x720h.mp4"] playModel:[SJPlayModel UICollectionViewCellPlayModelWithPlayerSuperviewTag:cell.backgroundImageView.tag atIndexPath:[self.collectionView indexPathForCell:cell] collectionView:self.collectionView]];
    [self.videoPlayerHelper playWithAsset:asset playerParentView:cell.backgroundImageView];
}

// please lazy load
@synthesize videoPlayerHelper = _videoPlayerHelper;
- (SJVideoPlayerHelper *)videoPlayerHelper {
    if ( _videoPlayerHelper ) return _videoPlayerHelper;
    _videoPlayerHelper = [[SJVideoPlayerHelper alloc] initWithViewController:self];
    _videoPlayerHelper.enableFilmEditing = YES;
    return _videoPlayerHelper;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.videoPlayerHelper.vc_viewDidAppearExeBlock();
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.videoPlayerHelper.vc_viewWillDisappearExeBlock();
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.videoPlayerHelper.vc_viewDidDisappearExeBlock();
}

- (BOOL)prefersStatusBarHidden {
    return self.videoPlayerHelper.vc_prefersStatusBarHiddenExeBlock();
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.videoPlayerHelper.vc_preferredStatusBarStyleExeBlock();
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 99;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PlayerCollectionViewCell *cell = (PlayerCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:PlayerCollectionViewCellID forIndexPath:indexPath];
    cell.delegate = self;
    return cell;
}
@end
