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
#import "SJVideoPlayerControlView.h"


@interface SJVideoPlayerMoreSettingsView (UICollectionViewDataSourceMethods)<UICollectionViewDataSource>
@end

@interface SJVideoPlayerMoreSettingsView (UICollectionViewDelegateMethods)<UICollectionViewDelegate>
@end


static NSString *const SJVideoPlayerMoreSettingsColCellID = @"SJVideoPlayerMoreSettingsColCell";

static NSString *const SJVideoPlayerMoreSettingsFooterSlidersViewID = @"SJVideoPlayerMoreSettingsFooterSlidersView";

@interface SJVideoPlayerMoreSettingsView ()

@property (nonatomic, strong, readonly) UICollectionView *colView;

@end

@implementation SJVideoPlayerMoreSettingsView

@synthesize colView = _colView;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _SJVideoPlayerMoreSettingsViewSetupUI];
    return self;
}

- (void)setMoreSettings:(NSArray<SJVideoPlayerMoreSetting *> *)moreSettings {
    _moreSettings = moreSettings;
    [self.colView reloadData];
}

- (void)_SJVideoPlayerMoreSettingsViewSetupUI {
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.85];
    [self addSubview:self.colView];
    [_colView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    self.layer.shadowOffset = CGSizeMake(0.5, 0.5);
    self.layer.shadowColor = [UIColor colorWithWhite:0 alpha:0.25].CGColor;
    self.layer.shadowOpacity = 1;
}

- (UICollectionView *)colView {
    if ( _colView ) return _colView;
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.footerReferenceSize = CGSizeMake(0, 200);
    _colView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    [_colView registerClass:NSClassFromString(SJVideoPlayerMoreSettingsColCellID) forCellWithReuseIdentifier:SJVideoPlayerMoreSettingsColCellID];
    [_colView registerClass:NSClassFromString(SJVideoPlayerMoreSettingsFooterSlidersViewID) forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:SJVideoPlayerMoreSettingsFooterSlidersViewID];
    _colView.dataSource = self;
    _colView.delegate = self;
    return _colView;
}

@end


@implementation SJVideoPlayerMoreSettingsView (UICollectionViewDataSourceMethods)

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
    SJVideoPlayerMoreSettingsFooterSlidersView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:SJVideoPlayerMoreSettingsFooterSlidersViewID forIndexPath:indexPath];
    return footerView;
}

@end




@implementation SJVideoPlayerMoreSettingsView (UICollectionViewDelegateMethods)

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = floor(self.frame.size.width / 3);
    return CGSizeMake( width, width);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if ( 0 == section ) return UIEdgeInsetsMake(20, 0, 0, 0);
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

@end
