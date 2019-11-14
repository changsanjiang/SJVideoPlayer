//
//  SJViewController.m
//  SJVideoPlayer
//
//  Created by changsanjiang on 06/08/2019.
//  Copyright (c) 2019 changsanjiang. All rights reserved.
//

#import "SJViewController.h"
#import <Masonry/Masonry.h>
#import <SJRouter/SJRouter.h>
#import "LWZTableSectionShrinker.h"
#import <SJVideoPlayer/SJVideoPlayer.h>

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

@interface SJViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<LWZTableSectionShrinker<Item *> *> *data;
@end

@implementation SJViewController

- (void)viewDidLoad
{
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
    
    [m addObject:[[LWZTableSectionShrinker alloc] initWithTitle:@"Rotation Control" titleWhenShrank:nil dataArr:[self _createRotationControlDemoItems]]];
    
    [m addObject:[[LWZTableSectionShrinker alloc] initWithTitle:@"Switching Control Layer" titleWhenShrank:nil dataArr:[self _createSwitchingControlLayerDemoItems]]];
    
    [m addObject:[[LWZTableSectionShrinker alloc] initWithTitle:@"Custom Control Layer" titleWhenShrank:nil dataArr:[self _createCustomControlLayerDemoItems]]];
    
    [m addObject:[[LWZTableSectionShrinker alloc] initWithTitle:@"UITableView UICollectionView" titleWhenShrank:nil dataArr:[self _createScrollViewDemoItems]]];
    
    [m addObject:[[LWZTableSectionShrinker alloc] initWithTitle:@"Playback List Control" titleWhenShrank:nil dataArr:[self _createPlaybackListControlDemoItems]]];
    
    [m addObject:[[LWZTableSectionShrinker alloc] initWithTitle:@"Add Button Item To Control Layer" titleWhenShrank:nil dataArr:[self _createAddButtonItemToControlLayerDemoItems]]];
    
    [m addObject:[[LWZTableSectionShrinker alloc] initWithTitle:@"Pop Prompt Control" titleWhenShrank:nil dataArr:[self _createPromptDemoItems]]];
    
    [m addObject:[[LWZTableSectionShrinker alloc] initWithTitle:@"Switch Video Definition" titleWhenShrank:nil dataArr:[self _createSwitchVideoDefinitionDemoItems]]];
    
    [m addObject:[[LWZTableSectionShrinker alloc] initWithTitle:@"GIF Screenshot Export" titleWhenShrank:nil dataArr:[self _createExportDemoItems]]];
    
    [m addObject:[[LWZTableSectionShrinker alloc] initWithTitle:@"Other" titleWhenShrank:nil dataArr:[self _createOtherItems]]];
    
    [m addObject:[[LWZTableSectionShrinker alloc] initWithTitle:@"Test" titleWhenShrank:nil dataArr:[self _createTestItems]]];

    _data = m.copy;
}


- (NSArray<Item *> *)_createRotationControlDemoItems {
    return
    @[
      [[Item alloc] initWithTitle:@"Rotation Control 1"
                         subTitle:@"旋转控制 1"
                             path:@"demo/rotationMode/vc1"],
      
      [[Item alloc] initWithTitle:@"Rotation Control 2"
                         subTitle:@"旋转控制 2"
                             path:@"demo/rotationMode/vc2"],
      
      [[Item alloc] initWithTitle:@"Rotation Control 3"
                         subTitle:@"旋转控制 3"
                             path:@"demo/rotationMode/vc3"]
      ];
}

- (NSArray<Item *> *)_createPlaybackListControlDemoItems {
    return
    @[
      [[Item alloc] initWithTitle:@"Playback List Control"
                         subTitle:@"播放列表控制"
                             path:@"demo/playbackListControl/vc1"],
      ];
}

- (NSArray<Item *> *)_createAddButtonItemToControlLayerDemoItems {
    return
    @[
      [[Item alloc] initWithTitle:@"Add Button Item To Control Layer"
                         subTitle:@"添加按钮到控制层"
                             path:@"demo/controlLayer/edgeButtonItem"],
      ];
}

- (NSArray<Item *> *)_createScrollViewDemoItems {
    return
    @[
      [[Item alloc] initWithTitle:@"Float Small View"
                         subTitle:@"开启小浮窗 (注: 当播放器视图滑动消失时, 显示小浮窗视图)"
                             path:@"demo/scrollView/floatSmallView"],
      
      [[Item alloc] initWithTitle:@"Nested View"
                         subTitle:@"嵌套"
                             path:@"demo/scrollView/nested"],
      
      [[Item alloc] initWithTitle:@"Autoplay in Table View"
                         subTitle:@"TableView 中自动播放"
                             path:@"demo/tableView/autoplay2"],
      
      [[Item alloc] initWithTitle:@"Autoplay in CollectionView View"
                         subTitle:@"CollectionViewView 中自动播放"
                             path:@"demo/collectionView/autoplay3"]
      ];
}

- (NSArray<Item *> *)_createSwitchingControlLayerDemoItems {
    return
    @[
      [[Item alloc] initWithTitle:@"Switching Control Layer"
                         subTitle:@"切换控制层 (注: 此为手动切换, 实际过程中播放器将会根据状态自动切换)"
                             path:@"demo/controlLayer/switching"],
      ];
}

- (NSArray<Item *> *)_createCustomControlLayerDemoItems {
    return
    @[
      [[Item alloc] initWithTitle:@"Custom Control Layer"
                         subTitle:@"自定义控制层"
                             path:@"demo/CustomControlLayer/vc12"],
      ];
}

- (NSArray<Item *> *)_createPromptDemoItems {
    return
    @[
      [[Item alloc] initWithTitle:@"Prompt 1"
                         subTitle:@"弹出提示(左下角)"
                             path:@"demo/prompt1"],
      
      [[Item alloc] initWithTitle:@"Prompt 2"
                         subTitle:@"弹出提示(中间)"
                             path:@"demo/prompt2"],
      ];
}

- (NSArray<Item *> *)_createSwitchVideoDefinitionDemoItems {
    return
    @[
      [[Item alloc] initWithTitle:@"Switch Video Definition"
                         subTitle:@"切换视频清晰度"
                             path:@"demo/SwitchVideoDefinition"],
      ];
}

- (NSArray<Item *> *)_createExportDemoItems {
    return
    @[
      [[Item alloc] initWithTitle:@"GIF Screenshot Export"
                         subTitle:@"GIF Screenshot Export"
                             path:@"demo/export"],
      ];
}

- (NSArray<Item *> *)_createTestItems {
    return
    @[
        [[Item alloc] initWithTitle:@"Test subtitles"
                           subTitle:@"测试 字幕"
                               path:@"subtitles/demo"],
        [[Item alloc] initWithTitle:@"Test barrages"
                           subTitle:@"测试 弹幕"
                               path:@"barrage/demo"],
        [[Item alloc] initWithTitle:@"Test"
                           subTitle:@"Test"
                               path:@"test"],
        [[Item alloc] initWithTitle:@"Test IJK"
                           subTitle:@"Test IJK"
                               path:@"test2"],
        [[Item alloc] initWithTitle:@"Test Ali"
                           subTitle:@"Test Ali"
                               path:@"test3"],
        [[Item alloc] initWithTitle:@"Test AliyunVod"
                           subTitle:@"Test AliyunVod"
                               path:@"test4"],
      ];
}

- (NSArray<Item *> *)_createOtherItems {
    return
    @[
      [[Item alloc] initWithTitle:@"Right and left edge fast forward and fast backward"
                         subTitle:@"左右边缘双击 快进快退"
                             path:@"demo/11"],
      ];
}

#pragma mark -

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
