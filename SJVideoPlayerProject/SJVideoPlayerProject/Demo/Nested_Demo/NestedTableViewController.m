//
//  NestedTableViewController.m
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/1/11.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "NestedTableViewController.h"
#import "SJVideoPlayer.h"
#import "NestedTableViewCell.h"
#import "PlayerCollectionViewCell.h"
#import <Masonry.h>
#import "SJVideoPlayerHelper.h"

static NSString *const NestedTableViewCellID = @"NestedTableViewCell";

@interface NestedTableViewController ()<NestedTableViewCellDelegate, SJVideoPlayerHelperUseProtocol>

@property (nonatomic, strong, readonly) SJVideoPlayerHelper *videoPlayerHelper;

@end

@implementation NestedTableViewController

@synthesize videoPlayerHelper = _videoPlayerHelper;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Nested scrollView(嵌套view)";
    self.view.backgroundColor = [UIColor whiteColor];
    [self.tableView registerClass:NSClassFromString(NestedTableViewCellID) forCellReuseIdentifier:NestedTableViewCellID];
    self.tableView.rowHeight = [NestedTableViewCell height];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// lazy load
- (SJVideoPlayerHelper *)videoPlayerHelper {
    if ( _videoPlayerHelper ) return _videoPlayerHelper;
    _videoPlayerHelper = [[SJVideoPlayerHelper alloc] initWithViewController:self];
    return _videoPlayerHelper;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.videoPlayerHelper.vc_viewDidAppearExeBlock();
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


- (void)clickedPlayWithNestedTabCell:(NestedTableViewCell *)tabCell
                    playerParentView:(UIView *)playerParentView
                           indexPath:(NSIndexPath *)indexPath
                      collectionView:(UICollectionView *)collectionView {
  
    // create asset
    NSURL *playURL = [[NSBundle mainBundle] URLForResource:@"sample" withExtension:@"mp4"];
    
    NSIndexPath *embeddedScrollViewIndexPath = [self.tableView indexPathForCell:tabCell];
    UIView *embeddedScrollView = collectionView;
    SJVideoPlayerURLAsset *asset =
    [[SJVideoPlayerURLAsset alloc] initWithAssetURL:playURL
                                          indexPath:indexPath
                                       superviewTag:playerParentView.tag
                                scrollViewIndexPath:embeddedScrollViewIndexPath
                                      scrollViewTag:embeddedScrollView.tag
                                     rootScrollView:self.tableView];
    
    [self.videoPlayerHelper playWithAsset:asset playerParentView:playerParentView];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 99;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NestedTableViewCell *cell = (NestedTableViewCell *)[tableView dequeueReusableCellWithIdentifier:NestedTableViewCellID forIndexPath:indexPath];
    cell.delegate = self;
    return cell;
}

@end

