//
//  SJVideoPlayerMoreSettingTwoSettingsView.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/9/25.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerMoreSettingTwoSettingsView.h"
#import <Masonry/Masonry.h>
#import "UIView+SJExtension.h"
#import "SJVideoPlayerControlView.h"
#import "NSAttributedString+ZFBAdditon.h"
#import "SJVideoPlayerMoreSettingTwoSettingsHeaderView.h"
#import "SJVideoPlayerMoreSettingTwoSetting.h"

@interface SJVideoPlayerMoreSettingTwoSettingsView (ColDataSourceMethods)<UICollectionViewDataSource>
@end

@interface SJVideoPlayerMoreSettingTwoSettingsView (UICollectionViewDelegateMethods)<UICollectionViewDelegate>
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
    
    self.layer.shadowOffset = CGSizeMake(-1, 0);
    self.layer.shadowColor = [UIColor colorWithWhite:0 alpha:0.5].CGColor;
    self.layer.shadowRadius = 1;
    self.layer.shadowOpacity = 1;
}

- (UICollectionView *)colView {
    if ( _colView ) return _colView;
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.headerReferenceSize = CGSizeMake(0, [SJVideoPlayerMoreSettingTwoSetting topTitleFontSize] * 1.2 + 20);
    _colView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    [_colView registerClass:NSClassFromString(SJVideoPlayerMoreSettingTwoSettingsColCellID) forCellWithReuseIdentifier:SJVideoPlayerMoreSettingTwoSettingsColCellID];
    [_colView registerClass:NSClassFromString(SJVideoPlayerMoreSettingTwoSettingsHeaderViewID) forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:SJVideoPlayerMoreSettingTwoSettingsHeaderViewID];
    _colView.dataSource = self;
    _colView.delegate = self;
    
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
    self.headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:SJVideoPlayerMoreSettingTwoSettingsHeaderViewID forIndexPath:indexPath];
    self.headerView.model = self.twoLevelSettings;
    return self.headerView;
}

@end



@implementation SJVideoPlayerMoreSettingTwoSettingsView (UICollectionViewDelegateMethods)

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.csj_w / 3 - 1, self.csj_w / 3);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

@end
