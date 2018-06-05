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


static NSString *const PlayerTableViewCellID = @"PlayerTableViewCell";

@interface PlayerTableViewController ()<PlayerTableViewCellDelegate>

@property (nonatomic, strong, readwrite) SJVideoPlayer *videoPlayer;

@end

@implementation PlayerTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"TableView";
    
    self.view.backgroundColor = [UIColor whiteColor];

    [self.tableView registerClass:NSClassFromString(PlayerTableViewCellID) forCellReuseIdentifier:PlayerTableViewCellID];
    
    self.tableView.rowHeight = [PlayerTableViewCell height];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 99;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PlayerTableViewCell *cell = (PlayerTableViewCell *)[tableView dequeueReusableCellWithIdentifier:PlayerTableViewCellID forIndexPath:indexPath];
    cell.delegate = self;
    return cell;
}

- (void)clickedPlayOnTabCell:(PlayerTableViewCell *)cell {
    [self _removeOldPlayer];
    
    
    [self _createNewPlayerWithView:cell.backgroundImageView indexPath:[self.tableView indexPathForCell:cell] tag:cell.backgroundImageView.tag videoURLStr:@"https://www.apple.com/105/media/us/iphone-x/2017/01df5b43-28e4-4848-bf20-490c34a926a7/films/feature/iphone-x-feature-tpl-cc-us-20170912_1280x720h.mp4"];
}

- (void)_removeOldPlayer {
//     clear old player
    SJVideoPlayer *oldPlayer = _videoPlayer;
    if ( !oldPlayer ) { return; }

    // stop and fade out
    [oldPlayer stopAndFadeOut];
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
        self->_videoPlayer.view.alpha = 1;
    }];
    
    _videoPlayer.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithAssetURL:[NSURL URLWithString:videoURLStr] scrollView:self.tableView indexPath:indexPath superviewTag:tag];
    
    _videoPlayer.autoPlay = YES;
}

@end
