//
//  VideoPlayerTableViewController.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/8/28.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "VideoPlayerTableViewController.h"

#import "SJPlayer.h"

static NSString *const VideoPlayerTableViewCellID = @"VideoPlayerTableViewCell";


@interface VideoPlayerTableViewController ()

@property (nonatomic, assign, readwrite) NSTimeInterval currentTime;

@end

@implementation VideoPlayerTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [SJVideoPlayer sharedPlayer].placeholder = [UIImage imageNamed:@"sj_video_player_placeholder"];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableView.rowHeight = [UIScreen mainScreen].bounds.size.width * 9 / 16 + 6;
    
    [self.tableView registerClass:NSClassFromString(VideoPlayerTableViewCellID) forCellReuseIdentifier:VideoPlayerTableViewCellID];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 99;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:VideoPlayerTableViewCellID forIndexPath:indexPath];
    [cell setValue:self forKey:@"delegate"];
    return cell;
}

@end


#import "VideoPlayerTableViewCell.h"

#import <Masonry/Masonry.h>

@interface VideoPlayerTableViewController (VideoPlayerTableViewCellDelegateMethods)<VideoPlayerTableViewCellDelegate>

@end


@implementation VideoPlayerTableViewController (VideoPlayerTableViewCellDelegateMethods)

- (void)clickedPlayBtnOnTheCell:(VideoPlayerTableViewCell *)cell onViewTag:(NSInteger)tag {
    [SJVideoPlayer sharedPlayer].assetURL = [[NSBundle mainBundle] URLForResource:@"sample.mp4" withExtension:nil];
    [cell.videoImageView addSubview:[SJVideoPlayer sharedPlayer].view];
    [[SJVideoPlayer sharedPlayer].view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    [[SJVideoPlayer sharedPlayer] setScrollView:self.tableView indexPath:[self.tableView indexPathForCell:cell] onViewTag:tag];
}

@end
