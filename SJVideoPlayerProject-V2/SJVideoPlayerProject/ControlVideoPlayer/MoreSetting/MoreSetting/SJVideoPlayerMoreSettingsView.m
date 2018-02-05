//
//  SJVideoPlayerMoreSettingsView.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/9/25.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerMoreSettingsView.h"
#import "SJVideoPlayerMoreSettingsFooterSlidersView.h"
#import <Masonry/Masonry.h>
#import "UIView+SJVideoPlayerSetting.h"
#import <SJUIFactory/SJUIFactory.h>

static NSString *const SJVideoPlayerMoreSettingsColCellID = @"SJVideoPlayerMoreSettingsColCell";

static NSString *const SJVideoPlayerMoreSettingsFooterSlidersViewID = @"SJVideoPlayerMoreSettingsFooterSlidersView";


@interface SJVideoPlayerMoreSettingsView ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong, readonly) UICollectionView *colView;

@end

@implementation SJVideoPlayerMoreSettingsView {
    SJVideoPlayerMoreSettingsFooterSlidersView *_footerView;
}

@synthesize colView = _colView;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _moreSettingsViewSetupUI];
    [self _moreSettingsHelper];
    [SJUIFactory boundaryProtectedWithView:self];
    return self;
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(SJScreen_Max() * 0.382, SJScreen_Min());
}

//- (void)setFullscreen:(BOOL)fullscreen {
//    _fullscreen = fullscreen;
//    [self.colView reloadData];
//}

#pragma mark -

- (void)setMoreSettings:(NSArray<SJVideoPlayerMoreSetting *> *)moreSettings {
    _moreSettings = moreSettings;
    [self.colView reloadData];
}

- (void)setFooterViewModel:(SJMoreSettingsFooterViewModel *)footerViewModel {
    _footerViewModel = footerViewModel;
    _footerView.model = footerViewModel;
}

- (void)_moreSettingsViewSetupUI {
    [self addSubview:self.colView];
    [_colView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_colView.superview);
    }];
}

- (UICollectionView *)colView {
    if ( _colView ) return _colView;
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    _colView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    [_colView registerClass:NSClassFromString(SJVideoPlayerMoreSettingsColCellID) forCellWithReuseIdentifier:SJVideoPlayerMoreSettingsColCellID];
    [_colView registerClass:NSClassFromString(SJVideoPlayerMoreSettingsFooterSlidersViewID) forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:SJVideoPlayerMoreSettingsFooterSlidersViewID];
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
    _footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:SJVideoPlayerMoreSettingsFooterSlidersViewID forIndexPath:indexPath];
    _footerView.model = _footerViewModel;
    return _footerView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = floor(self.frame.size.width / 3);
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
    return CGSizeMake(self.intrinsicContentSize.width, [SJVideoPlayerMoreSettingsFooterSlidersView height]);
}

#pragma mark -
- (void)_moreSettingsHelper {
    self.settingRecroder = [[SJVideoPlayerControlSettingRecorder alloc] initWithSettings:^(SJVideoPlayerSettings * _Nonnull setting) {
        self.colView.backgroundColor = self.backgroundColor = setting.moreBackgroundColor;
    }];
}
@end
