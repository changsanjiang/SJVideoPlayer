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
#import <SJSlider/SJSlider.h>
#import <SJOrentationObserver/SJOrentationObserver.h>
#import <SJObserverHelper/NSObject+SJObserverHelper.h>

static NSString *const SJVideoPlayerMoreSettingsColCellID = @"SJVideoPlayerMoreSettingsColCell";

static NSString *const SJVideoPlayerMoreSettingsFooterSlidersViewID = @"SJVideoPlayerMoreSettingsFooterSlidersView";


@interface SJVideoPlayerMoreSettingsView ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak, readonly) SJOrentationObserver *orentationObserver;

@property (nonatomic, strong, readonly) UICollectionView *colView;

@end

@implementation SJVideoPlayerMoreSettingsView {
    SJVideoPlayerMoreSettingsFooterSlidersView *_footerView;
}

@synthesize colView = _colView;

- (instancetype)initWithOrentationObserver:(SJOrentationObserver * _Nonnull __weak)orentationObserver {
    self = [super initWithFrame:CGRectZero];
    if ( !self ) return nil;
    _orentationObserver = orentationObserver;
    [self _moreSettingsViewSetupUI];
    [self _moreSettingsAddObserve];
    return self;
}

- (void)_moreSettingsAddObserve {
    [self.orentationObserver sj_addObserver:self forKeyPath:@"fullScreen"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ( [keyPath isEqualToString:@"fullScreen"] ) {
        if ( _orentationObserver.fullScreen ) [self.colView reloadData];
    }
}

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
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
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
    if ( 0 == _moreSettings.count ) return CGSizeMake(self.bounds.size.width, [UIScreen mainScreen].bounds.size.height - 2 * (collectionView.contentInset.top + collectionView.contentInset.bottom));
    return CGSizeMake(self.bounds.size.width, [SJVideoPlayerMoreSettingsFooterSlidersView height]);
}
@end
