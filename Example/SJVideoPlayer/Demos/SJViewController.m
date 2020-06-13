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
    
    [m addObject:[[LWZTableSectionShrinker alloc] initWithTitle:@"DY" titleWhenShrank:nil dataArr:[self _DYDemoItems]]];

    [m addObject:[[LWZTableSectionShrinker alloc] initWithTitle:@"Rotation Control" titleWhenShrank:nil dataArr:[self _createRotationControlDemoItems]]];
    
    [m addObject:[[LWZTableSectionShrinker alloc] initWithTitle:@"UITableView Demo" titleWhenShrank:nil dataArr:[self _UITableViewDemoItems]]];
    
    [m addObject:[[LWZTableSectionShrinker alloc] initWithTitle:@"UITableView Demo" titleWhenShrank:nil dataArr:[self _UICollectionViewDemoItems]]];
    
    [m addObject:[[LWZTableSectionShrinker alloc] initWithTitle:@"Keyboard Handle Demo" titleWhenShrank:nil dataArr:[self _KeyboardHandleDemoItems]]];
    
    [m addObject:[[LWZTableSectionShrinker alloc] initWithTitle:@"Switching Control Layer" titleWhenShrank:nil dataArr:[self _createSwitchingControlLayerDemoItems]]];
    
    [m addObject:[[LWZTableSectionShrinker alloc] initWithTitle:@"Custom Control Layer" titleWhenShrank:nil dataArr:[self _createCustomControlLayerDemoItems]]];
     
    [m addObject:[[LWZTableSectionShrinker alloc] initWithTitle:@"Playback List Control" titleWhenShrank:nil dataArr:[self _createPlaybackListControlDemoItems]]];
    
    [m addObject:[[LWZTableSectionShrinker alloc] initWithTitle:@"Add Button Item To Control Layer" titleWhenShrank:nil dataArr:[self _createAddButtonItemToControlLayerDemoItems]]];
    
    [m addObject:[[LWZTableSectionShrinker alloc] initWithTitle:@"Pop Prompt Control" titleWhenShrank:nil dataArr:[self _createPromptDemoItems]]];
    
    [m addObject:[[LWZTableSectionShrinker alloc] initWithTitle:@"Switch Video Definition" titleWhenShrank:nil dataArr:[self _createSwitchVideoDefinitionDemoItems]]];
    
    [m addObject:[[LWZTableSectionShrinker alloc] initWithTitle:@"GIF Screenshot Export" titleWhenShrank:nil dataArr:[self _createExportDemoItems]]];
    
    [m addObject:[[LWZTableSectionShrinker alloc] initWithTitle:@"Other" titleWhenShrank:nil dataArr:[self _createOtherItems]]];
    
    [m addObject:[[LWZTableSectionShrinker alloc] initWithTitle:@"Test" titleWhenShrank:nil dataArr:[self _createTestItems]]];

    [m addObject:[[LWZTableSectionShrinker alloc] initWithTitle:@"Third-party Player" titleWhenShrank:nil dataArr:[self _thirdpartyPlayerItems]]];
    

    _data = m.copy;
}


- (NSArray<Item *> *)_DYDemoItems {
    return @[
        [Item.alloc initWithTitle:@"1 DY" subTitle:nil path:@"dy/1"],
    ];
}

- (NSArray<Item *> *)_KeyboardHandleDemoItems {
    return @[
        [Item.alloc initWithTitle:@"1 TextField" subTitle:nil path:@"Keyboard/1"],
    ];
}

- (NSArray<Item *> *)_UICollectionViewDemoItems {
    return @[
        [Item.alloc initWithTitle:@"1 Play In `collectionView.cell`" subTitle:@"在`collectionView.cell`中播放" path:@"UICollectionView/1"],
        
        [Item.alloc initWithTitle:@"2 Play In `collectionView.sectionHeaderView`" subTitle:@"在`collectionView.sectionHeaderView`中播放" path:@"UICollectionView/2"],
        
        [Item.alloc initWithTitle:@"3 Play In `collectionView.sectionFooterView`" subTitle:@"在`collectionView.sectionFooterView`中播放" path:@"UICollectionView/3"],

        [Item.alloc initWithTitle:@"4 Play In `collectionView.cell.collectionView.cell`" subTitle:@"在`collectionView.cell.collectionView.cell`中播放" path:@"UICollectionView/4"],

        [Item.alloc initWithTitle:@"5 Autoplay In `collectionView.cell`" subTitle:@"在`collectionView.cell`中自动播放" path:@"UICollectionView/5"],

    ];
}

- (NSArray<Item *> *)_UITableViewDemoItems {
    return @[
        [Item.alloc initWithTitle:@"1 Play In `tableView.cell`" subTitle:@"在`tableView.cell`中播放" path:@"UITableViewDemo/1"],
        
        [Item.alloc initWithTitle:@"2 Play In `tableView.tableHeaderView`" subTitle:@"在`tableView.tableHeaderView`中播放" path:@"UITableViewDemo/2"],
        
        [Item.alloc initWithTitle:@"3 Play In `tableView.tableFooterView`" subTitle:@"在`tableView.tableFooterView`中播放" path:@"UITableViewDemo/3"],
        
        [Item.alloc initWithTitle:@"4 Play In `tableView.sectionHeaderView`" subTitle:@"在`tableView.sectionHeaderView`中播放" path:@"UITableViewDemo/4"],
        
        [Item.alloc initWithTitle:@"5 Play In `tableView.sectionFooterView`" subTitle:@"在`tableView.sectionFooterView`中播放" path:@"UITableViewDemo/5"],
        
        [Item.alloc initWithTitle:@"6 Play In `tableView.cell.collectionView.cell`" subTitle:@"在`tableView.cell.collectionView.cell`中播放" path:@"UITableViewDemo/6"],

        [Item.alloc initWithTitle:@"7 🔥 Play In `pageViewController.headerView`" subTitle:@"在`pageViewController.headerView`中播放" path:@"UITableViewDemo/7"],

        [Item.alloc initWithTitle:@"8 Autoplay In `tableView.cell`" subTitle:@"在`tableView.cell`中自动播放" path:@"UITableViewDemo/8"],
        
        [Item.alloc initWithTitle:@"9 Enable floatSmallView" subTitle:@"开启小浮窗 (注: 当播放器视图滑动消失时, 显示小浮窗视图)" path:@"UITableViewDemo/9"],

    ];
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
        [[Item alloc] initWithTitle:@"Test playback history"
                           subTitle:@"测试 播放记录"
                               path:@"playbackHistory"],
        [[Item alloc] initWithTitle:@"Test"
                           subTitle:@"Test"
                               path:@"test"],
      ];
}

- (NSArray<Item *> *)_thirdpartyPlayerItems {
    return
    @[
        [[Item alloc] initWithTitle:@"ijkplayer"
                           subTitle:@""
                               path:@"thirdpartyPlayer/ijkplayer"],
        [[Item alloc] initWithTitle:@"AliPlayer"
                           subTitle:@""
                               path:@"thirdpartyPlayer/AliPlayer"],
        [[Item alloc] initWithTitle:@"AliyunVodPlayer"
                           subTitle:@""
                               path:@"thirdpartyPlayer/AliyunVodPlayer"],
        [[Item alloc] initWithTitle:@"PLPlayer"
                           subTitle:@""
                               path:@"thirdpartyPlayer/PLPlayer"],
      ];

}

- (NSArray<Item *> *)_createOtherItems {
    return
    @[
      [[Item alloc] initWithTitle:@"Long Press Fast-forward"
                         subTitle:@"长按快进"
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
