//
//  SJViewController5mm.m
//  SJVideoPlayer_Example
//
//  Created by BlueDancer on 2020/3/1.
//  Copyright © 2020 changsanjiang. All rights reserved.
//

#import "SJViewController5mm.h"
#import <SJVideoPlayer/SJVideoPlayer.h>
#import <SJUIKit/NSAttributedString+SJMake.h>
#import <Masonry/Masonry.h>
#import "SJTableViewHeaderFooterView5n.h"
#import "SJMediasTableViewModel.h"
#import "SJSourceURLs.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJTableHeaderView : UIView
@property (nonatomic, strong, readonly) UIView *containerView;
@end

@implementation SJTableHeaderView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( self ) {
        _containerView = [UIView.alloc initWithFrame:CGRectZero];
        [self addSubview:_containerView];
        [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.offset(0);
        }];
    }
    return self;
}
@end


@interface SJViewController5mm ()<UITableViewDataSource,  UITableViewDelegate, SJMediaItemsTableViewCellDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong, nullable) SJVideoPlayer *player;
@end

@implementation SJViewController5mm

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViews];
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
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, self.view.bounds.size.height, 0);
    
    SJTableHeaderView *headerView = [SJTableHeaderView.alloc initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 300)];;
    _tableView.tableHeaderView = headerView;
    
    _player = SJVideoPlayer.player;
    SJPlayModel *playModel = [SJPlayModel UITableViewHeaderViewPlayModelWithPlayerSuperview:headerView.containerView tableView:self.tableView];
    SJVideoPlayerURLAsset *asset = [SJVideoPlayerURLAsset.alloc initWithURL:SourceURL0 playModel:playModel];
    _player.URLAsset = asset;
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

- (BOOL)prefersStatusBarHidden {
    return [self.player vc_prefersStatusBarHidden];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [self.player vc_preferredStatusBarStyle];
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

@end
NS_ASSUME_NONNULL_END

#pragma mark -
#import <SJRouter/SJRouter.h>
@interface SJViewController5mm (RouteHandler)<SJRouteHandler>

@end

@implementation SJViewController5mm (RouteHandler)

+ (NSString *)routePath {
    return @"demo/scrollView/nested2";
}

+ (void)handleRequest:(SJRouteRequest *)request topViewController:(UIViewController *)topViewController completionHandler:(SJCompletionHandler)completionHandler {
    [topViewController.navigationController pushViewController:[SJViewController5mm new] animated:YES];
}

@end
