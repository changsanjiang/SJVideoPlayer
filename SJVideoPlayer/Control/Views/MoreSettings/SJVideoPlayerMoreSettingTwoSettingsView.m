//
//  SJVideoPlayerMoreSettingTwoSettingsView.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/9/25.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerMoreSettingTwoSettingsView.h"
#import "SJVideoPlayer.h"
#import <Masonry/Masonry.h>
#import "UIView+SJExtension.h"
#import "SJVideoPlayerControlView.h"
#import "NSAttributedString+ZFBAdditon.h"
#import "SJVideoPlayerMoreSettingTwoSettingsHeaderView.h"

@interface SJVideoPlayerMoreSettingTwoSettingsView (ColDataSourceMethods)<UICollectionViewDataSource>
@end


static NSString *const SJVideoPlayerMoreSettingTwoSettingsColCellID = @"SJVideoPlayerMoreSettingTwoSettingsColCell";

static NSString *const SJVideoPlayerMoreSettingTwoSettingsHeaderViewID = @"SJVideoPlayerMoreSettingTwoSettingsHeaderView";

@interface SJVideoPlayerMoreSettingTwoSettingsView ()
@property (nonatomic, strong, readonly) UICollectionView *colView;
@property (nonatomic, strong, readwrite) SJVideoPlayerMoreSettingTwoSettingsHeaderView *headerView;
@end

@implementation SJVideoPlayerMoreSettingTwoSettingsView

@synthesize colView = _colView;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _SJVideoPlayerMoreSettingTwoSettingsViewSetupUI];
    [self addPanGR];
    return self;
}

- (void)addPanGR {
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGR:)];
    [self addGestureRecognizer:pan];
}

- (void)handlePanGR:(UIPanGestureRecognizer *)pan {}

- (void)setTwoLevelSettings:(SJVideoPlayerMoreSetting *)twoLevelSettings {
    _twoLevelSettings = twoLevelSettings;
    [self.colView reloadData];
}

// MARK: UI

- (void)_SJVideoPlayerMoreSettingTwoSettingsViewSetupUI {
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.85];
    [self addSubview:self.colView];
    [_colView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
}

- (UICollectionView *)colView {
    if ( _colView ) return _colView;
    CGFloat itemW_H = floor(SJMoreSettings_W / 3);
    _colView = [UICollectionView collectionViewWithItemSize:CGSizeMake(itemW_H, itemW_H) backgroundColor:[UIColor clearColor] scrollDirection:UICollectionViewScrollDirectionVertical headerSize:CGSizeMake(SJMoreSettings_W, [SJVideoPlayerMoreSettingTwoSetting topTitleFontSize] * 1.2 + 20) footerSize:CGSizeZero];
    [_colView registerClass:NSClassFromString(SJVideoPlayerMoreSettingTwoSettingsColCellID) forCellWithReuseIdentifier:SJVideoPlayerMoreSettingTwoSettingsColCellID];
    [_colView registerClass:NSClassFromString(SJVideoPlayerMoreSettingTwoSettingsHeaderViewID) forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:SJVideoPlayerMoreSettingTwoSettingsHeaderViewID];
    _colView.dataSource = self;
    return _colView;
}

@end

@implementation SJVideoPlayerMoreSettingTwoSettingsView (ColDataSourceMethods)

// MARK: UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.twoLevelSettings.twoSettingItems.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:SJVideoPlayerMoreSettingTwoSettingsColCellID forIndexPath:indexPath];
    [cell setValue:self.twoLevelSettings.twoSettingItems[indexPath.row] forKey:@"model"];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ( ![kind isEqualToString:UICollectionElementKindSectionHeader] ) return nil;
    self.headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:SJVideoPlayerMoreSettingTwoSettingsHeaderViewID forIndexPath:indexPath];
    self.headerView.model = self.twoLevelSettings;
    return self.headerView;
}

@end
