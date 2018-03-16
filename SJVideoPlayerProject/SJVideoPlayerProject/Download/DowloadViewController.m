//
//  DowloadViewController.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/3/16.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "DowloadViewController.h"
#import <SJUIFactory/SJUIFactory.h>
#import <Masonry/Masonry.h>
#import "SJMediaDownloader.h"
#import "DownloadTableViewCell.h"
#import "SJVideo.h"

static NSString *const DownloadTableViewCellID = @"DownloadTableViewCell";

@interface DowloadViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong, readonly) UITableView *tableView;
@property (nonatomic, strong) NSArray<id<SJMediaEntity>> *downloadMedias;

@end

@implementation DowloadViewController
@synthesize tableView = _tableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _setupViews];
    
    // Do any additional setup after loading the view.
}

#pragma mark -
- (void)_setupViews {
    [self.view addSubview:self.tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Download" style:UIBarButtonItemStyleDone target:self action:@selector(prepareTestData)];
}

- (void)prepareTestData {
    NSArray<SJVideo *> *videos = [SJVideo testVideos];
    [videos enumerateObjectsUsingBlock:^(SJVideo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[SJMediaDownloader shared] async_downloadWithID:obj.mediaId title:obj.title mediaURLStr:obj.playURLStr tmpEntity:nil];
    }];
    
    __weak typeof(self) _self = self;
    [[SJMediaDownloader shared] async_requestMediasCompletion:^(SJMediaDownloader * _Nonnull downloader, NSArray<id<SJMediaEntity>> * _Nullable medias) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            self.downloadMedias = medias;
            [self.tableView reloadData];
        });
    }];
}

- (UITableView *)tableView {
    if ( _tableView ) return _tableView;
    _tableView = [SJUITableViewFactory tableViewWithStyle:UITableViewStylePlain backgroundColor:[UIColor whiteColor] separatorStyle:UITableViewCellSeparatorStyleNone showsVerticalScrollIndicator:YES delegate:self dataSource:self];
    [_tableView registerClass:NSClassFromString(DownloadTableViewCellID) forCellReuseIdentifier:DownloadTableViewCellID];
    return _tableView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [DownloadTableViewCell height];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ( _downloadMedias ) return _downloadMedias.count;
    return 99;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DownloadTableViewCell *cell = (DownloadTableViewCell *)[tableView dequeueReusableCellWithIdentifier:DownloadTableViewCellID forIndexPath:indexPath];
    if ( _downloadMedias ) {
        cell.model = _downloadMedias[indexPath.row];
    }
    return cell;
}
@end
