//
//  SJVideoPlayerMoreSettingsView.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/9/25.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerMoreSettingsView.h"
#import "SJVideoPlayerMoreSettingsSlidersView.h"
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif
#import "UIView+SJVideoPlayerSetting.h"
#if __has_include(<SJUIFactory/SJUIFactory.h>)
#import <SJUIFactory/SJUIFactory.h>
#else
#import "SJUIFactory.h"
#endif
#import "SJVideoPlayerMoreSettingsFooterView.h"



static NSString *const SJVideoPlayerMoreSettingsColCellID = @"SJVideoPlayerMoreSettingsColCell";

static NSString *const SJVideoPlayerMoreSettingsFooterViewID = @"SJVideoPlayerMoreSettingsFooterView";


@interface SJVideoPlayerMoreSettingsView ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong, readonly) UICollectionView *colView;
@property (nonatomic, strong, readonly) SJVideoPlayerMoreSettingsSlidersView *slidersView;

@end

@implementation SJVideoPlayerMoreSettingsView

@synthesize slidersView = _slidersView;
@synthesize colView = _colView;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _moreSettingsViewSetupUI];
    [self _moreSettingsHelper];
    return self;
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(ceil(SJScreen_Max() * 0.4), SJScreen_Min());
}

- (SJVideoPlayerMoreSettingsSlidersView *)slidersView {
    if ( _slidersView ) return _slidersView;
    _slidersView = [SJVideoPlayerMoreSettingsSlidersView new];
    _slidersView.frame = (CGRect){CGPointZero, _slidersView.intrinsicContentSize};
    return _slidersView;
}

#pragma mark -

- (void)setMoreSettings:(NSArray<SJVideoPlayerMoreSetting *> *)moreSettings {
    _moreSettings = moreSettings;
    [self.colView reloadData];
}

- (void)_moreSettingsViewSetupUI {
    [self addSubview:self.colView];
    [_colView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self->_colView.superview);
    }];
    
    [self slidersView];
}

- (UICollectionView *)colView {
    if ( _colView ) return _colView;
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    _colView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    [_colView registerClass:NSClassFromString(SJVideoPlayerMoreSettingsColCellID) forCellWithReuseIdentifier:SJVideoPlayerMoreSettingsColCellID];
    [_colView registerClass:NSClassFromString(SJVideoPlayerMoreSettingsFooterViewID) forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:SJVideoPlayerMoreSettingsFooterViewID];
    _colView.dataSource = self;
    _colView.delegate = self;
    _colView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    return _colView;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _moreSettings.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:SJVideoPlayerMoreSettingsColCellID forIndexPath:indexPath];
    [cell setValue:_moreSettings[indexPath.row] forKey:@"model"];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    SJVideoPlayerMoreSettingsFooterView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:SJVideoPlayerMoreSettingsFooterViewID forIndexPath:indexPath];
    [footerView addSubview:self.slidersView];
    [_slidersView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    self.slidersView.model = self.footerViewModel;
    return footerView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = floor(self.intrinsicContentSize.width / 3);
    return CGSizeMake( width, width);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    if ( 0 == _moreSettings.count ) return CGSizeMake(self.intrinsicContentSize.width, self.intrinsicContentSize.height - 2 * (collectionView.contentInset.top + collectionView.contentInset.bottom));
    return self.slidersView.intrinsicContentSize;
}

#pragma mark -
- (void)_moreSettingsHelper {
    self.settingRecroder = [[SJVideoPlayerControlSettingRecorder alloc] initWithSettings:^(SJEdgeControlLayerSettings * _Nonnull setting) {
        self.colView.backgroundColor = self.backgroundColor = setting.moreBackgroundColor;
    }];
}
@end
