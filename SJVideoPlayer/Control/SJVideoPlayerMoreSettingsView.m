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
#import "UIView+SJExtension.h"
#import "SJVideoPlayerControlView.h"
#import <SJSlider/SJSlider.h>


@interface SJVideoPlayerMoreSettingsView (DBNotifications)
- (void)_installNotifications;
- (void)_removeNotifications;
@end

@interface SJVideoPlayerMoreSettingsView (UICollectionViewDataSourceMethods)<UICollectionViewDataSource>
@end

@interface SJVideoPlayerMoreSettingsView (UICollectionViewDelegateMethods)<UICollectionViewDelegate>
@end


static NSString *const SJVideoPlayerMoreSettingsColCellID = @"SJVideoPlayerMoreSettingsColCell";

static NSString *const SJVideoPlayerMoreSettingsFooterSlidersViewID = @"SJVideoPlayerMoreSettingsFooterSlidersView";

@interface SJVideoPlayerMoreSettingsView ()
@property (nonatomic, strong, readonly) UICollectionView *colView;
- (void)getMoreSettingsSlider:(void(^)(SJSlider *volumeSlider, SJSlider *brightnessSlider, SJSlider *rateSlider))block;
@property (nonatomic, copy, readwrite) void(^getFooterCallBlock)(SJSlider *volumeSlider, SJSlider *brightnessSlider, SJSlider *rateSlider);
@property (nonatomic, strong, readonly) NSMutableArray<void(^)(SJSlider *volumeSlider, SJSlider *brightnessSlider, SJSlider *rateSlider)> *exeBlocks;
@end

@implementation SJVideoPlayerMoreSettingsView

@synthesize footerView = _footerView;
@synthesize colView = _colView;
@synthesize exeBlocks = _exeBlocks;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _SJVideoPlayerMoreSettingsViewSetupUI];
    [self _installNotifications];
    [self addPanGR];
    return self;
}

- (void)dealloc {
    [self _removeNotifications];
}

- (void)setMoreSettings:(NSArray<SJVideoPlayerMoreSetting *> *)moreSettings {
    _moreSettings = moreSettings;
    [self.colView reloadData];
}

- (void)setFooterView:(SJVideoPlayerMoreSettingsFooterSlidersView *)footerView {
    _footerView = footerView;
    [self.exeBlocks enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(void (^ _Nonnull obj)(SJSlider *, SJSlider *, SJSlider *), NSUInteger idx, BOOL * _Nonnull stop) {
        obj(_footerView.volumeSlider, _footerView.brightnessSlider, _footerView.rateSlider);
        [self.exeBlocks removeObject:obj];
    }];
}

- (void)getMoreSettingsSlider:(void (^)(SJSlider *, SJSlider *, SJSlider *))block {
    if ( !block ) return;
    if ( self.footerView ) {
        block(_footerView.volumeSlider, _footerView.brightnessSlider, _footerView.rateSlider);
        return;
    }
    [self.exeBlocks addObject:block];
}

- (void)addPanGR {
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGR:)];
    [self addGestureRecognizer:pan];
}

- (void)handlePanGR:(UIPanGestureRecognizer *)pan {}


- (void)_SJVideoPlayerMoreSettingsViewSetupUI {
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
    flowLayout.footerReferenceSize = CGSizeMake(0, 200);
    _colView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];

    [_colView registerClass:NSClassFromString(SJVideoPlayerMoreSettingsColCellID) forCellWithReuseIdentifier:SJVideoPlayerMoreSettingsColCellID];
    [_colView registerClass:NSClassFromString(SJVideoPlayerMoreSettingsFooterSlidersViewID) forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:SJVideoPlayerMoreSettingsFooterSlidersViewID];
    _colView.dataSource = self;
    _colView.delegate = self;
    return _colView;
}

- (NSMutableArray<void (^)(SJSlider *, SJSlider *, SJSlider *)> *)exeBlocks {
    if ( _exeBlocks ) return _exeBlocks;
    _exeBlocks = [NSMutableArray new];
    return _exeBlocks;
}

@end


@implementation SJVideoPlayerMoreSettingsView (UICollectionViewDataSourceMethods)


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.moreSettings.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:SJVideoPlayerMoreSettingsColCellID forIndexPath:indexPath];
    [cell setValue:self.moreSettings[indexPath.row] forKey:@"model"];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ( ![kind isEqualToString:UICollectionElementKindSectionFooter] ) return nil;
    self.footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:SJVideoPlayerMoreSettingsFooterSlidersViewID forIndexPath:indexPath];
    return self.footerView;
}

@end




@implementation SJVideoPlayerMoreSettingsView (UICollectionViewDelegateMethods)

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.csj_w / 3 - 1, self.csj_w / 3);
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




#pragma mark -



#import "SJVideoPlayerStringConstant.h"
#import "SJVideoPlayerSettings.h"

@implementation SJVideoPlayerMoreSettingsView (DBNotifications)

- (void)_installNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsPlayerNotification:) name:SJSettingsPlayerNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reset) name:SJPlayerFullScreenNotitication object:nil];
}

- (void)_removeNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)settingsPlayerNotification:(NSNotification *)notifi {
    SJVideoPlayerSettings *settings = notifi.object;
    [self getMoreSettingsSlider:^(SJSlider *volumeSlider, SJSlider *brightnessSlider, SJSlider *rateSlider) {
        if ( settings.traceColor ) {
            volumeSlider.traceImageView.backgroundColor = settings.traceColor;
            brightnessSlider.traceImageView.backgroundColor = settings.traceColor;
            rateSlider.traceImageView.backgroundColor = settings.traceColor;
        }
        if ( settings.trackColor ) {
            volumeSlider.trackImageView.backgroundColor = settings.trackColor;
            brightnessSlider.trackImageView.backgroundColor = settings.trackColor;
            rateSlider.trackImageView.backgroundColor = settings.trackColor;
        }
    }];
}

- (void)reset {
    [self.colView reloadData];
}

@end
