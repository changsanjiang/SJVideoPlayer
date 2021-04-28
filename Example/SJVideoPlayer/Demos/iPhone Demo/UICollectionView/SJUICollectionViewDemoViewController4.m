//
//  SJUICollectionViewDemoViewController1.m
//  SJVideoPlayer_Example
//
//  Created by BlueDancer on 2020/5/10.
//  Copyright © 2020 changsanjiang. All rights reserved.
//

#import "SJUICollectionViewDemoViewController4.h"
#import <Masonry/Masonry.h>
#import <SJVideoPlayer/SJVideoPlayer.h>
#import "SJRecommendVideosViewModel.h"

@interface SJUICollectionViewDemoViewController4 ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, SJRecommendVideosCollectionViewCellDelegate>
@property (nonatomic, strong, readonly) UICollectionView *collectionView;
@property (nonatomic, strong, nullable) SJVideoPlayer *player;
@property (nonatomic, strong) NSArray<SJRecommendVideosViewModel *> *viewModels;
@end

@implementation SJUICollectionViewDemoViewController4

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViews];
    
    // 模拟数据
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableArray<SJRecommendVideosViewModel *> *m = [[NSMutableArray alloc] initWithCapacity:20];
        NSArray<NSString *> *testTitles = @[@"悲哀化身-内蒙专区", @"车迟国@最终幻想-剑侠风骨", @"老虎222-天竺国", @"今朝醉-云中殿", @"杀手阿七-五明宫", @"浅墨淋雨桥-剑胆琴心"];
        
        for ( int i = 0 ; i < 20 ; ++ i ) {
            NSString *title = testTitles[arc4random() % testTitles.count];
            [m addObject:[[SJRecommendVideosViewModel alloc] initWithTitle:title items:[SJVideoModel testItems]]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.viewModels = m;
            [self.collectionView reloadData];
        });
    });
}

- (void)cell:(SJRecommendVideosCollectionViewCell *)cell coverItemWasTappedInCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath {
    if ( _player == nil ) {
        _player = [SJVideoPlayer player];
        _player.resumePlaybackWhenScrollAppeared = YES; //< 滚动出现时, 是否恢复播放, 此处设置为YES.
    }
    
    SJRecommendVideosViewModel *videos = (id)cell.dataSource;
    SJExtendedMediaCollectionViewModel *video = videos.medias[indexPath.item];
    
    // 视图层次第一层
    SJPlayModel *playModel = [SJPlayModel playModelWithCollectionView:collectionView indexPath:indexPath superviewSelector:NSSelectorFromString(@"coverImageView")];
    // 视图层次第二层
    // 通过`nextPlayModel`链起来
    SJPlayModel *next = [SJPlayModel playModelWithCollectionView:_collectionView indexPath:[_collectionView indexPathForCell:cell]];
    next.scrollViewSelector = NSSelectorFromString(@"collectionView");
    playModel.nextPlayModel = next;
    
    // 进行播放
    _player.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithURL:video.url playModel:playModel];
}

#pragma mark -

- (void)_setupViews {
    self.title = NSStringFromClass(self.class);
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    
    [SJRecommendVideosCollectionViewCell registerWithCollectionView:_collectionView];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return _viewModels.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [SJRecommendVideosCollectionViewCell cellWithCollectionView:_collectionView indexPath:indexPath];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.view.bounds.size.width, _viewModels[indexPath.item].height);
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(SJRecommendVideosCollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    cell.dataSource = self.viewModels[indexPath.item];
    cell.delegate = self;
}

@synthesize collectionView = _collectionView;
- (UICollectionView *)collectionView {
    if ( _collectionView == nil ) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = UIColor.whiteColor;
        [SJVideoCollectionViewCell registerWithCollectionView:_collectionView];
    }
    return _collectionView;
}

#pragma mark -

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
