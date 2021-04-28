//
//  SJUITableViewDemoViewController6.m
//  SJVideoPlayer_Example
//
//  Created by BlueDancer on 2020/5/10.
//  Copyright © 2020 changsanjiang. All rights reserved.
//

#import "SJUITableViewDemoViewController6.h"
#import <SJVideoPlayer/SJVideoPlayer.h>
#import <SJUIKit/NSAttributedString+SJMake.h>
#import <Masonry/Masonry.h>
#import "SJRecommendVideosViewModel.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJUITableViewDemoViewController6 ()<UITableViewDataSource,  UITableViewDelegate, SJRecommendVideosTableViewCellDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<SJRecommendVideosViewModel *> *viewModels;
@property (nonatomic, strong, nullable) SJVideoPlayer *player;
@end

@implementation SJUITableViewDemoViewController6

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
            [self.tableView reloadData];
        });
    });
}
 
- (void)cell:(SJRecommendVideosTableViewCell *)cell coverItemWasTappedInCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath {
    if ( _player == nil ) {
        _player = [SJVideoPlayer player];
        _player.resumePlaybackWhenScrollAppeared = YES; //< 滚动出现时, 是否恢复播放, 此处设置为YES.
    }
    
    SJRecommendVideosViewModel *videos = (id)cell.dataSource;
    SJExtendedMediaCollectionViewModel *video = videos.medias[indexPath.item];
    
    
    // 视图层次第一层
    SJPlayModel *playModel = [SJPlayModel playModelWithCollectionView:collectionView indexPath:indexPath superviewSelector:NSSelectorFromString(@"coverImageView")];
    // 视图层次第二层
    // 通过`next`链起来
    SJPlayModel *next = [SJPlayModel playModelWithTableView:_tableView indexPath:[_tableView indexPathForCell:cell]];
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
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.offset(0);
        make.width.offset(UIScreen.mainScreen.bounds.size.width);
    }];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.estimatedRowHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.001)];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [SJRecommendVideosTableViewCell registerWithNib:[UINib nibWithNibName:@"SJRecommendVideosTableViewCell" bundle:nil] tableView:_tableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _viewModels.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 80;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [SJRecommendVideosTableViewCell cellWithTableView:tableView indexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return _viewModels[indexPath.section].height;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(SJRecommendVideosTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.dataSource = _viewModels[indexPath.section];
    cell.delegate = self;
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
NS_ASSUME_NONNULL_END
