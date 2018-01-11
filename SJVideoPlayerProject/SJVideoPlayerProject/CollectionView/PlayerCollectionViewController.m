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
#import "SJVideoPlayer.h"

static NSString * const PlayerCollectionViewCellID = @"PlayerCollectionViewCell";

@interface PlayerCollectionViewController ()<PlayerCollectionViewCellDelegate>

@property (nonatomic, strong, readwrite) SJVideoPlayer *videoPlayer;

@end

@implementation PlayerCollectionViewController

- (instancetype)init
{
    UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
    flowLayout.itemSize = [PlayerCollectionViewCell itemSize];
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self = [super initWithCollectionViewLayout:flowLayout];
    if (self) { }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"CollectionView";

    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerClass:[PlayerCollectionViewCell class] forCellWithReuseIdentifier:PlayerCollectionViewCellID];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _videoPlayer.disableRotation = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _videoPlayer.disableRotation = YES;
}

- (void)dealloc {
    [_videoPlayer stop];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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

#pragma mark <UICollectionViewDelegate>
- (void)clickedPlayOnColCell:(PlayerCollectionViewCell *)cell {
    [self _removeOldPlayer];

    [self _createNewPlayerWithView:cell.backgroundImageView indexPath:[self.collectionView indexPathForCell:cell] tag:cell.backgroundImageView.tag videoURLStr:@"http://video.cdn.lanwuzhe.com/usertrend/166162-1513873330.mp4"];
}

- (void)_removeOldPlayer {
    // clear old player
    SJVideoPlayer *oldPlayer = _videoPlayer;
    if ( !oldPlayer ) return;
    // fade out
    [UIView animateWithDuration:0.5 animations:^{
        oldPlayer.view.alpha = 0.001;
    } completion:^(BOOL finished) {
        [oldPlayer stop];
        [oldPlayer.view removeFromSuperview];
    }];
}

- (void)_createNewPlayerWithView:(UIView *)view
                       indexPath:(NSIndexPath *)indexPath
                             tag:(NSInteger)tag
                     videoURLStr:(NSString *)videoURLStr {
    // create new player
    _videoPlayer = [SJVideoPlayer player];
    _videoPlayer.view.alpha = 0.001;
    [view addSubview:_videoPlayer.view];
    [_videoPlayer.view mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    // fade in
    [UIView animateWithDuration:0.5 animations:^{
        _videoPlayer.view.alpha = 1;
    }];
    
    _videoPlayer.asset = [[SJVideoPlayerAssetCarrier alloc] initWithAssetURL:[NSURL URLWithString:videoURLStr] scrollView:self.collectionView indexPath:indexPath superviewTag:tag];
    
    _videoPlayer.autoplay = YES;
}

@end
