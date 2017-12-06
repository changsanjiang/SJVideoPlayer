//
//  PlayerTableViewController.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/12/6.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "PlayerTableViewController.h"
#import "SJVideoPlayer.h"
#import "PlayerTableViewCell.h"
#import <Masonry.h>

#define TabPlayer  [SJVideoPlayer sharedPlayer]


static NSString *const PlayerTableViewCellID = @"PlayerTableViewCell";

@interface PlayerTableViewController ()

@end

@implementation PlayerTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];

    [self.tableView registerClass:NSClassFromString(PlayerTableViewCellID) forCellReuseIdentifier:PlayerTableViewCellID];
    
    self.tableView.rowHeight = 200;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [TabPlayer stop];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 99;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PlayerTableViewCellID forIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (  TabPlayer.asset.indexPath != indexPath ) {
        PlayerTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.backgroundImageView.userInteractionEnabled = YES;
        cell.backgroundImageView.tag = 100;
        [cell.backgroundImageView addSubview:TabPlayer.view];
        
        [TabPlayer.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.offset(0);
        }];
        
        SJVideoPlayerAssetCarrier *asset = [[SJVideoPlayerAssetCarrier alloc] initWithAssetURL:[NSURL URLWithString:@"http://vod.lanwuzhe.com/d09d3a5f9ba4491fa771cd63294ad349%2F0831eae12c51428fa7aed3825c511370-5287d2089db37e62345123a1be272f8b.mp4"] scrollView:tableView indexPath:indexPath superviewTag:100];
        TabPlayer.asset = asset;
    }
}

@end
