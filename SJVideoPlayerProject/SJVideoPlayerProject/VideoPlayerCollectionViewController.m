//
//  VideoPlayerCollectionViewController.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/8/28.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "VideoPlayerCollectionViewController.h"

#import "VideoPlayerCollectionViewCell.h"

#import "SJPlayer.h"


@interface VideoPlayerCollectionViewController ()

@property (nonatomic, assign, readwrite) NSTimeInterval currentTime;

@end

@implementation VideoPlayerCollectionViewController

static NSString * const VideoPlayerCollectionViewCellID = @"VideoPlayerCollectionViewCell";


- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
    UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
    flowLayout.itemSize = CGSizeMake([UIScreen mainScreen].bounds.size.width * 0.5, [UIScreen mainScreen].bounds.size.width * 0.5 * 9 / 16.);
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    self = [super initWithCollectionViewLayout:flowLayout];
    if ( !self ) return nil;
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerClass:NSClassFromString(VideoPlayerCollectionViewCellID) forCellWithReuseIdentifier:VideoPlayerCollectionViewCellID];
    
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[SJVideoPlayer sharedPlayer] jumpedToTime:self.currentTime completionHandler:^(BOOL finished) {
        [[SJVideoPlayer sharedPlayer] play];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.currentTime = [SJVideoPlayer sharedPlayer].currentTime;
    [[SJVideoPlayer sharedPlayer] pause];
    
// MARK: Clicked Back Button
    __weak typeof(self) _self = self;
    [SJVideoPlayer sharedPlayer].clickedBackEvent = ^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.navigationController popViewControllerAnimated:YES];
    };
}

- (void)dealloc {
    [[SJVideoPlayer sharedPlayer] stop];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 99;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:VideoPlayerCollectionViewCellID forIndexPath:indexPath];
    [cell setValue:self forKey:@"delegate"];

    return cell;
}

@end



#import <Masonry/Masonry.h>

@interface VideoPlayerCollectionViewController (VideoPlayerCollectionViewCellDelegateMethods)<VideoPlayerCollectionViewCellDelegate>

@end


@implementation VideoPlayerCollectionViewController (VideoPlayerCollectionViewCellDelegateMethods)

- (void)clickedPlayBtnOnTheCell:(VideoPlayerCollectionViewCell *)cell onViewTag:(NSInteger)tag {
    [SJVideoPlayer sharedPlayer].assetURL = [[NSBundle mainBundle] URLForResource:@"sample.mp4" withExtension:nil];
    [cell.videoImageView addSubview:[SJVideoPlayer sharedPlayer].view];
    [[SJVideoPlayer sharedPlayer].view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    [[SJVideoPlayer sharedPlayer] setScrollView:self.collectionView indexPath:[self.collectionView indexPathForCell:cell] onViewTag:tag];
}

@end
