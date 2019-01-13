//
//  ViewController.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2018/9/29.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import "ViewController.h"
#import <Masonry/Masonry.h>
#import <SJRouter/SJRouter.h>
#import "LWZTableSectionShrinker.h"
//#import <SJFullscreenPopGesture/UINavigationController+SJVideoPlayerAdd.h>
//#import <SJFullscreenPopGesture/UIViewController+SJVideoPlayerAdd.h>

@interface Item : NSObject
- (instancetype)initWithTitle:(NSString *)title subTitle:(NSString *)subTitle path:(NSString *)path;
@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, strong, readonly) NSString *subTitle;
@property (nonatomic, strong, readonly) NSString *path;
@end
@implementation Item
- (instancetype)initWithTitle:(NSString *)title subTitle:(NSString *)subTitle path:(NSString *)path {
    self = [super init];
    if ( !self ) return nil;
    _title = title;
    _subTitle = subTitle;
    _path = path;
    return self;
}
@end

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<LWZTableSectionShrinker<Item *> *> *data;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self _createDemoData];
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.estimatedRowHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    _tableView.rowHeight = 44;
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)_createDemoData {
    NSMutableArray<LWZTableSectionShrinker<Item *> *> *m = [NSMutableArray new];
    
    [m addObject:[[LWZTableSectionShrinker alloc] initWithTitle:@"Player Type" titleWhenShrank:nil dataArr:[self _createItemsBySJPlayerType]]];
    
    [m addObject:[[LWZTableSectionShrinker alloc] initWithTitle:@"Control Rotation" titleWhenShrank:nil dataArr:[self _createItemsBySJControlRotation]]];
    
    [m addObject:[[LWZTableSectionShrinker alloc] initWithTitle:@"Button Item Operations For Control Layer" titleWhenShrank:nil dataArr:[self _createItemsByButtonItemOperationsForControlLayer]]];
    
    [m addObject:[[LWZTableSectionShrinker alloc] initWithTitle:@"Play Model Demo" titleWhenShrank:nil dataArr:[self _createItemsBySJPlayModel]]];
    
    [m addObject:[[LWZTableSectionShrinker alloc] initWithTitle:@"List View Auto Play" titleWhenShrank:nil dataArr:[self _createItemsBySJListViewAutoplay]]];
    
    [m addObject:[[LWZTableSectionShrinker alloc] initWithTitle:@"Paging Playback" titleWhenShrank:nil dataArr:[self _createItemsByPagingPlayback]]];
    
    [m addObject:[[LWZTableSectionShrinker alloc] initWithTitle:@"Continue Playing" titleWhenShrank:nil dataArr:[self _createItemsByContinuePlaying]]];
    
    [m addObject:[[LWZTableSectionShrinker alloc] initWithTitle:@"Control Layer Switcher" titleWhenShrank:nil dataArr:[self _createItemsByControlLayerSwitcher]]];
    
    [m addObject:[[LWZTableSectionShrinker alloc] initWithTitle:@"Prefetcher" titleWhenShrank:nil dataArr:[self _createItemsByPrefetcher]]];
    
    [m addObject:[[LWZTableSectionShrinker alloc] initWithTitle:@"Other" titleWhenShrank:nil dataArr:[self _createItemsByOtherOperations]]];
    
    [m addObject:[[LWZTableSectionShrinker alloc] initWithTitle:@"Test Adapter" titleWhenShrank:nil dataArr:[self _createItemsByTestAdapter]]];
    _data = m.copy;
}

- (NSArray<Item *> *)_createItemsByPrefetcher {
    return
    @[[[Item alloc] initWithTitle:@"Prefetcher"
                         subTitle:@"预加载"
                             path:@"asset/prefetcher"]];
}

- (NSArray<Item *> *)_createItemsByControlLayerSwitcher {
    return
    @[[[Item alloc] initWithTitle:@"Replace control Layer"
                         subTitle:@"替换默认的控制层"
                             path:@"player/defaultPlayer/switcher/replaceControlLayer"]];
}

- (NSArray<Item *> *)_createItemsByButtonItemOperationsForControlLayer {
    return
    @[[[Item alloc] initWithTitle:@"Add & Remove & Update Item"
                         subTitle:@"在控制层中`添加``移除``更新`按钮"
                             path:@"player/defaultPlayer/addItem"],
      
      [[Item alloc] initWithTitle:@"Adjust button items location"
                         subTitle:@"调整控制层中 按钮的位置"
                             path:@"player/defaultPlayer/adjust"],
      
      [[Item alloc] initWithTitle:@"Other button item examples"
                         subTitle:@"Button Item 的各种使用"
                             path:@"player/defaultPlayer/itemExamples"]];
}

- (NSArray<Item *> *)_createItemsBySJPlayModel {
    return
  @[[[Item alloc] initWithTitle:@"SJPlayModel"
                       subTitle:@"在普通视图上播放"
                           path:@"view/playbackInfo"],
    
    [[Item alloc] initWithTitle:@"SJUITableViewCellPlayModel"
                       subTitle:@"在TableView单元格中播放"
                           path:@"tableView/cell/play"],
    
    [[Item alloc] initWithTitle:@"SJUICollectionViewCellPlayModel"
                       subTitle:@"在CollectionView单元格中播放"
                           path:@"collectionView/cell/play"],
    
    [[Item alloc] initWithTitle:@"SJUITableViewHeaderViewPlayModel"
                       subTitle:@"在TableView的TableHeaderView中播放"
                           path:@"tableView/tableHeaderView/play"],
    
    [[Item alloc] initWithTitle:@"TableFooterView"
                       subTitle:@"在TableView的TableFooterView中播放"
                           path:@"tableView/tableFooterView/play"],
    
    [[Item alloc] initWithTitle:@"SJUICollectionViewNestedInUITableViewHeaderViewPlayModel"
                       subTitle:@"在CollectionView单元格中播放, 嵌套在TableViewHeader中"
                           path:@"tableView/tableHeaderView/collectionView/cell/play"],
    
    [[Item alloc] initWithTitle:@"SJUICollectionViewNestedInUITableViewCellPlayModel"
                       subTitle:@"在CollectionView单元格中播放, 嵌套在TableViewCell中"
                           path:@"tableView/cell/collectionView/cell/play"],
    
    [[Item alloc] initWithTitle:@"SJUICollectionViewNestedInUICollectionViewCellPlayModel"
                       subTitle:@"在CollectionView单元格中播放, 嵌套在CollectionViewCell中"
                           path:@"collectionView/cell/collectionView/cell/play"],
    
    [[Item alloc] initWithTitle:@"SJUITableViewHeaderFooterViewPlayModel"
                       subTitle:@"在TableViewHeaderFooterView中播放"
                           path:@"tableView/headerFooterView/play"],
    ];
}

- (NSArray<Item *> *)_createItemsBySJControlRotation {
    return
    @[[[Item alloc] initWithTitle:@"Control Rotation"
                         subTitle:@"旋转控制"
                             path:@"rotation/control"],
      
      [[Item alloc] initWithTitle:@"Fit On Screen"
                         subTitle:@"使全屏, 但不旋转"
                             path:@"player/fitOnScreen"],
      
      [[Item alloc] initWithTitle:@"Fit On Screen V2"
                         subTitle:@"使全屏, 但不旋转, V2"
                             path:@"player/fitOnScreenV2"],
      
      [[Item alloc] initWithTitle:@"Full Screen Playback"
                         subTitle:@"直接全屏播放"
                             path:@"player/fullscreen"]];
}

- (NSArray<Item *> *)_createItemsBySJPlayerType {
    return
    @[[[Item alloc] initWithTitle:@"Default player"
                         subTitle:@"默认播放器"
                             path:@"player/defaultPlayer"],
      
      [[Item alloc] initWithTitle:@"Lightweight player"
                         subTitle:@"轻量级播放器"
                             path:@"player/lightweightPlayer"],];
}

- (NSArray<Item *> *)_createItemsBySJListViewAutoplay {
    return
    @[[[Item alloc] initWithTitle:@"TableView Autoplay"
                         subTitle:@"TableView自动播放"
                             path:@"tableView/autoplay"],
      
      [[Item alloc] initWithTitle:@"CollectionView Autoplay"
                         subTitle:@"CollectionView自动播放"
                             path:@"collectionView/autoplay"],];
}

- (NSArray<Item *> *)_createItemsByPagingPlayback {
    return
    @[[[Item alloc] initWithTitle:@"PageViewController"
                         subTitle:@"分页播放"
                             path:@"pagingPlayback/pageViewController"],];
}

- (NSArray<Item *> *)_createItemsByContinuePlaying {
    return
    @[[[Item alloc] initWithTitle:@"ContinuePlayingOnTheNewViewController"
                         subTitle:@"在新界面继续播放"
                             path:@"player/continuePlaying"],
      [[Item alloc] initWithTitle:@"ContinuePlayingWhenAppDidEnterBackground"
                         subTitle:@"当App进入后台继续播放"
                             path:@"player/continuePlayingOnTheBackground"]];
}

- (NSArray<Item *> *)_createItemsByOtherOperations {
    return
    @[[[Item alloc] initWithTitle:@"Set playback rate"
                         subTitle:@"调整播放速度"
                             path:@"player/setPlaybackRate"],
      
      [[Item alloc] initWithTitle:@"UpdateResources"
                         subTitle:@"修改默认的图片等资源"
                             path:@"player/updateResources"],
      
      [[Item alloc] initWithTitle:@"GIF Screenshot Export"
                         subTitle:@"GIF Screenshot Export 示例"
                             path:@"player/filmEditing"],
      
      [[Item alloc] initWithTitle:@"CustomControlLayer"
                         subTitle:@"自定义控制层"
                             path:@"player/customControlLayer"],
      
      [[Item alloc] initWithTitle:@"VideoFlipTransition"
                         subTitle:@"镜像翻转"
                             path:@"player/videoFlipTransition"],
      
      [[Item alloc] initWithTitle:@"Test Alert"
                         subTitle:@"测试 弹窗"
                             path:@"player/defaultPlayer/testAlert"],
      
      [[Item alloc] initWithTitle:@"Test"
                         subTitle:@"测试"
                             path:@"player/test"]];
}

- (NSArray<Item *> *)_createItemsByTestAdapter {
    return
    @[[[Item alloc] initWithTitle:@"Test Adapter"
                         subTitle:@"测试 Adapter"
                             path:@"test/testAdapter"]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _data.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return _data[section].titleForShrinkStatus;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _data[section].dataArrByShrinkStatus.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *UITableViewCellID = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:UITableViewCellID];
    if ( !cell ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:UITableViewCellID];
        cell.textLabel.font = [UIFont systemFontOfSize:12];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:10];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.textLabel.text = _data[indexPath.section].dataArrByShrinkStatus[indexPath.row].title;
    cell.detailTextLabel.text = _data[indexPath.section].dataArrByShrinkStatus[indexPath.row].subTitle;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SJRouteRequest *reqeust = [[SJRouteRequest alloc] initWithPath:_data[indexPath.section].dataArrByShrinkStatus[indexPath.row].path parameters:nil];
    [SJRouter.shared handleRequest:reqeust completionHandler:nil];
}
@end
