//
//  SJVideoPlayerMoreSettingSecondaryView.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/12/5.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerMoreSettingSecondaryView.h"
#import <Masonry/Masonry.h>
#import "SJVideoPlayerMoreSettingsSecondaryHeaderView.h"
#import "SJVideoPlayerMoreSettingSecondary.h"
#import <SJUIFactory/SJUIFactory.h>
#import "UIView+SJVideoPlayerSetting.h"


@interface SJVideoPlayerMoreSettingSecondaryView (ColDataSourceMethods)<UICollectionViewDataSource>
@end

@interface SJVideoPlayerMoreSettingSecondaryView (UICollectionViewDelegateMethods)<UICollectionViewDelegate>
@end


static NSString *const SJVideoPlayerMoreSettingSecondaryColCellID = @"SJVideoPlayerMoreSettingSecondaryColCell";

static NSString *const SJVideoPlayerMoreSettingsSecondaryHeaderViewID = @"SJVideoPlayerMoreSettingsSecondaryHeaderView";

@interface SJVideoPlayerMoreSettingSecondaryView ()

@property (nonatomic, strong, readonly) UICollectionView *colView;
@property (nonatomic, strong, readwrite) SJVideoPlayerMoreSettingsSecondaryHeaderView *headerView;

@end

@implementation SJVideoPlayerMoreSettingSecondaryView

@synthesize colView = _colView;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _secondarySettingSetupUI];
    [self _secondarySettingHelper];
    return self;
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(ceil(SJScreen_Max() * 0.4), SJScreen_Min());
}

- (void)setTwoLevelSettings:(SJVideoPlayerMoreSetting *)twoLevelSettings {
    _twoLevelSettings = twoLevelSettings;
    [self.colView reloadData];
}

- (void)_secondarySettingSetupUI {
    [self addSubview:self.colView];
    [_colView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self->_colView.superview);
    }];
}

- (UICollectionView *)colView {
    if ( _colView ) return _colView;
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.headerReferenceSize = CGSizeMake(0, [SJVideoPlayerMoreSettingSecondary topTitleFontSize] * 1.2 + 20);
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    _colView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    [_colView registerClass:NSClassFromString(SJVideoPlayerMoreSettingSecondaryColCellID) forCellWithReuseIdentifier:SJVideoPlayerMoreSettingSecondaryColCellID];
    [_colView registerClass:NSClassFromString(SJVideoPlayerMoreSettingsSecondaryHeaderViewID) forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:SJVideoPlayerMoreSettingsSecondaryHeaderViewID];
    _colView.dataSource = self;
    _colView.delegate = self;
    
    return _colView;
}

- (void)_secondarySettingHelper {
    __weak typeof(self) _self = self;
    self.settingRecroder = [[SJVideoPlayerControlSettingRecorder alloc] initWithSettings:^(SJEdgeControlLayerSettings * _Nonnull setting) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.colView.backgroundColor = self.backgroundColor = setting.moreBackgroundColor;
    }];
}

@end

@implementation SJVideoPlayerMoreSettingSecondaryView (ColDataSourceMethods)

// MARK: UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.twoLevelSettings.twoSettingItems.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:SJVideoPlayerMoreSettingSecondaryColCellID forIndexPath:indexPath];
    [cell setValue:self.twoLevelSettings.twoSettingItems[indexPath.row] forKey:@"model"];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    self.headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:SJVideoPlayerMoreSettingsSecondaryHeaderViewID forIndexPath:indexPath];
    self.headerView.model = self.twoLevelSettings;
    return self.headerView;
}

@end



@implementation SJVideoPlayerMoreSettingSecondaryView (UICollectionViewDelegateMethods)

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = floor( self.intrinsicContentSize.width / 3);
    return CGSizeMake( width, width );
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}
@end
