//
//  SJVideoPlayerControlView.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/8/18.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerControlView.h"

#import <SJSlider/SJSlider.h>

#import <UIKit/UIKit.h>

#import "UIView+SJExtension.h"

#import <Masonry/Masonry.h>

#import "NSAttributedString+ZFBAdditon.h"

#import <objc/message.h>

#import "NSTimer+SJExtension.h"

#import "SJVideoPlayerStringConstant.h"

#import "SJVideoPlayer.h"

#import <SJBorderLineView/SJBorderlineView.h>

#import "JDradualLoadingView.h"

#define SJSCREEN_H  CGRectGetHeight([[UIScreen mainScreen] bounds])
#define SJSCREEN_W  CGRectGetWidth([[UIScreen mainScreen] bounds])

#define SJSCREEN_MIN MIN(SJSCREEN_H,SJSCREEN_W)
#define SJSCREEN_MAX MAX(SJSCREEN_H,SJSCREEN_W)

#define SJMoreSettings_W    ceil(SJSCREEN_MAX * 0.382)


#pragma mark -

typedef NS_ENUM(NSUInteger, SJMaskStyle) {
    SJMaskStyle_bottom,
    SJMaskStyle_top,
};

@interface SJMaskView : UIView
- (instancetype)initWithStyle:(SJMaskStyle)style;
@end

@interface SJMaskView ()
@property (nonatomic, assign, readwrite) SJMaskStyle style;
@end

@implementation SJMaskView {
    CAGradientLayer *_maskGradientLayer;
}

- (instancetype)initWithStyle:(SJMaskStyle)style {
    self = [super initWithFrame:CGRectZero];
    if ( !self ) return nil;
    self.style = style;
    [self initializeGL];
    return self;
}

- (void)initializeGL {
    self.backgroundColor = [UIColor clearColor];
    _maskGradientLayer = [CAGradientLayer layer];
    switch (_style) {
        case SJMaskStyle_top: {
            _maskGradientLayer.colors = @[(__bridge id)[UIColor colorWithWhite:0 alpha:0.42].CGColor,
                                          (__bridge id)[UIColor clearColor].CGColor];
        }
            break;
        case SJMaskStyle_bottom: {
            _maskGradientLayer.colors = @[(__bridge id)[UIColor clearColor].CGColor,
                                          (__bridge id)[UIColor colorWithWhite:0 alpha:0.42].CGColor];
        }
            break;
    }
    [self.layer addSublayer:_maskGradientLayer];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _maskGradientLayer.frame = self.bounds;
}

@end




#pragma mark -

@interface SJVideoPlayerMoreSettingsColCell : UICollectionViewCell
@property (nonatomic, strong) SJVideoPlayerMoreSetting *model;
@end


@interface SJVideoPlayerMoreSettingsColCell ()
@property (nonatomic, strong, readonly) UIButton *itemBtn;
@end

@implementation SJVideoPlayerMoreSettingsColCell

@synthesize itemBtn = _itemBtn;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _SJVideoPlayerMoreSettingsColCellSetupUI];
    return self;
}

- (void)clickedBtn:(UIButton *)btn {
    if ( self.model.clickedExeBlock ) self.model.clickedExeBlock(self.model);
}

- (void)setModel:(SJVideoPlayerMoreSetting *)model {
    _model = model;
    NSAttributedString *attr = [NSAttributedString mh_imageTextWithImage:model.image imageW:model.image.size.width imageH:model.image.size.height title:model.title ? model.title : @"" fontSize:[SJVideoPlayerMoreSetting titleFontSize] titleColor:[SJVideoPlayerMoreSetting titleColor] spacing:6];
    [_itemBtn setAttributedTitle:attr forState:UIControlStateNormal];
}

- (void)_SJVideoPlayerMoreSettingsColCellSetupUI {
    [self.contentView addSubview:self.itemBtn];
    [_itemBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
}

- (UIButton *)itemBtn {
    if ( _itemBtn ) return _itemBtn;
    _itemBtn = [UIButton buttonWithImageName:@"" tag:0 target:self sel:@selector(clickedBtn:)];
    _itemBtn.titleLabel.numberOfLines = 3;
    _itemBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    return _itemBtn;
}

@end


#pragma mark -

@interface SJVideoPlayerMoreSettingsFooterView : UICollectionReusableView
@property (nonatomic, strong, readonly) SJSlider *volumeSlider;
@property (nonatomic, strong, readonly) SJSlider *brightnessSlider;
@property (nonatomic, strong, readonly) SJSlider *rateSlider;
@end

@interface SJVideoPlayerMoreSettingsFooterView ()
@property (nonatomic, strong, readonly) UILabel *volumeLabel;
@property (nonatomic, strong, readonly) UILabel *brightnessLabel;
@property (nonatomic, strong, readonly) UILabel *rateLabel;
@end

@interface SJVideoPlayerMoreSettingsFooterView (DBObservers)
- (void)_SJVideoPlayerMoreSettingsFooterViewObservers;
- (void)_SJVideoPlayerMoreSettingsFooterViewRemoveObservers;
@end

@implementation SJVideoPlayerMoreSettingsFooterView

@synthesize volumeSlider = _volumeSlider;
@synthesize brightnessSlider = _brightnessSlider;
@synthesize rateSlider = _rateSlider;

@synthesize volumeLabel = _volumeLabel;
@synthesize brightnessLabel = _brightnessLabel;
@synthesize rateLabel = _rateLabel;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _SJVideoPlayerMoreSettingsFooterViewSetupUI];
    [self _SJVideoPlayerMoreSettingsFooterViewObservers];
    return self;
}

- (void)dealloc {
    [self _SJVideoPlayerMoreSettingsFooterViewRemoveObservers];
}

- (void)_SJVideoPlayerMoreSettingsFooterViewSetupUI {
    
    UIView *volumeBackgroundView = [UIView new];
    UIView *brightnessBackgroundView = [UIView new];
    UIView *rateBackgroundView = [UIView new];
    
    [self addSubview:volumeBackgroundView];
    [self addSubview:brightnessBackgroundView];
    [self addSubview:rateBackgroundView];
    
    [rateBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(25);
        make.leading.trailing.offset(0);
        make.height.offset((self.csj_h - 25 * 2) / 3);
        
    }];
    
    [volumeBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(rateBackgroundView.mas_bottom);
        make.leading.trailing.offset(0);
        make.height.equalTo(rateBackgroundView);
    }];
    
    [brightnessBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(volumeBackgroundView.mas_bottom);
        make.leading.trailing.offset(0);
        make.height.equalTo(volumeBackgroundView);
    }];
    
    
    [volumeBackgroundView addSubview:self.volumeLabel];
    [volumeBackgroundView addSubview:self.volumeSlider];
    
    [brightnessBackgroundView addSubview:self.brightnessLabel];
    [brightnessBackgroundView addSubview:self.brightnessSlider];
    
    [rateBackgroundView addSubview:self.rateLabel];
    [rateBackgroundView addSubview:self.rateSlider];
    
    [self _constraintsLabel:_volumeLabel slider:_volumeSlider];
    
    [self _constraintsLabel:_brightnessLabel slider:_brightnessSlider];
    
    [self _constraintsLabel:_rateLabel slider:_rateSlider];
    
}

- (void)_constraintsLabel:(UILabel *)label slider:(SJSlider *)slider {
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.offset(0);
        make.leading.offset(25);
    }];
    
    [slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.offset(0);
        make.trailing.offset(-25);
        make.leading.offset(99);
    }];
}


- (SJSlider *)volumeSlider {
    if ( _volumeSlider ) return _volumeSlider;
    _volumeSlider = [self slider];
    _volumeSlider.tag = SJVideoPlaySliderTag_Volume;
    return _volumeSlider;
}

- (UILabel *)volumeLabel {
    if ( _volumeLabel ) return _volumeLabel;
    _volumeLabel = [self label];
    _volumeLabel.text = @"音量";
    return _volumeLabel;
}

- (SJSlider *)brightnessSlider {
    if ( _brightnessSlider ) return _brightnessSlider;
    _brightnessSlider = [self slider];
    _brightnessSlider.tag = SJVideoPlaySliderTag_Brightness;
    return _brightnessSlider;
}

- (UILabel *)brightnessLabel {
    if ( _brightnessLabel ) return _brightnessLabel;
    _brightnessLabel = [self label];
    _brightnessLabel.text = @"亮度";
    return _brightnessLabel;
}

- (SJSlider *)rateSlider {
    if ( _rateSlider ) return _rateSlider;
    _rateSlider = [self slider];
    _rateSlider.tag = SJVideoPlaySliderTag_Rate;
    _rateSlider.minValue = 0.5;
    _rateSlider.maxValue = 2;
    _rateSlider.value = 1.0;
    return _rateSlider;
}

- (UILabel *)rateLabel {
    if ( _rateLabel ) return _rateLabel;
    _rateLabel = [self label];
    _rateLabel.text = @"调速";
    return _rateLabel;
}

- (UILabel *)label {
    return [UILabel labelWithFontSize:12 textColor:[UIColor whiteColor] alignment:NSTextAlignmentCenter];
}

- (SJSlider *)slider {
    SJSlider *slider = [SJSlider new];
    return slider;
}

@end

@implementation SJVideoPlayerMoreSettingsFooterView (DBObservers)


- (void)_SJVideoPlayerMoreSettingsFooterViewObservers {
    [self.volumeSlider addObserver:self forKeyPath:@"value" options:NSKeyValueObservingOptionNew context:nil];
    [self.rateSlider addObserver:self forKeyPath:@"value" options:NSKeyValueObservingOptionNew context:nil];
    [self.brightnessSlider addObserver:self forKeyPath:@"value" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)_SJVideoPlayerMoreSettingsFooterViewRemoveObservers {
    [self.volumeSlider removeObserver:self forKeyPath:@"value"];
    [self.rateSlider removeObserver:self forKeyPath:@"value"];
    [self.brightnessSlider removeObserver:self forKeyPath:@"value"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ( object == _volumeSlider ) _volumeLabel.text = [NSString stringWithFormat:@"音量  %.01f", _volumeSlider.value];
    if ( object == _rateSlider ) _rateLabel.text = [NSString stringWithFormat:@"调速  %.01f", _rateSlider.value];
    if ( object == _brightnessSlider ) _brightnessLabel.text = [NSString stringWithFormat:@"亮度  %.01f", _brightnessSlider.value];
}

@end

#pragma mark -


@interface SJVideoPlayerMoreSettingsView : UIView
@property (nonatomic, strong, readonly) SJVideoPlayerMoreSettingsFooterView *footerView;
@property (nonatomic, strong, readwrite) NSArray<SJVideoPlayerMoreSetting *> *moreSettings;
@end

@interface SJVideoPlayerMoreSettingsView (DBNotifications)
- (void)_installNotifications;
- (void)_removeNotifications;
@end

@interface SJVideoPlayerMoreSettingsView (UICollectionViewDataSourceMethods)<UICollectionViewDataSource>
@end

static NSString *const SJVideoPlayerMoreSettingsColCellID = @"SJVideoPlayerMoreSettingsColCell";

static NSString *const SJVideoPlayerMoreSettingsFooterViewID = @"SJVideoPlayerMoreSettingsFooterView";

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

- (void)setFooterView:(SJVideoPlayerMoreSettingsFooterView *)footerView {
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
        make.top.offset(25);
        make.leading.bottom.trailing.offset(0);
    }];
}

- (UICollectionView *)colView {
    if ( _colView ) return _colView;
    CGFloat itemW_H = floor(SJMoreSettings_W / 3);
    _colView = [UICollectionView collectionViewWithItemSize:CGSizeMake(itemW_H, itemW_H) backgroundColor:[UIColor clearColor] scrollDirection:UICollectionViewScrollDirectionVertical headerSize:CGSizeZero footerSize:CGSizeMake(SJMoreSettings_W, 200)];
    [_colView registerClass:NSClassFromString(SJVideoPlayerMoreSettingsColCellID) forCellWithReuseIdentifier:SJVideoPlayerMoreSettingsColCellID];
    [_colView registerClass:NSClassFromString(SJVideoPlayerMoreSettingsFooterViewID) forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:SJVideoPlayerMoreSettingsFooterViewID];
    _colView.dataSource = self;
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
    self.footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:SJVideoPlayerMoreSettingsFooterViewID forIndexPath:indexPath];
    return self.footerView;
}

@end


@implementation SJVideoPlayerMoreSettingsView (DBNotifications)

- (void)_installNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsPlayerNotification:) name:SJSettingsPlayerNotification object:nil];
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

@end




#pragma mark -


@interface SJVideoPlayerMoreSettingTwoSettingsCell : UICollectionViewCell
@property (nonatomic, strong, readwrite) SJVideoPlayerMoreSettingTwoSetting *model;
@end

@interface SJVideoPlayerMoreSettingTwoSettingsCell ()
@property (nonatomic, strong, readonly) UIButton *itemBtn;
@end

@implementation SJVideoPlayerMoreSettingTwoSettingsCell

@synthesize itemBtn = _itemBtn;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _SJVideoPlayerMoreSettingTwoSettingsCellSetupUI];
    return self;
}

- (void)clickedBtn:(UIButton *)btn {
    if ( self.model.clickedExeBlock ) self.model.clickedExeBlock(self.model);
}

- (void)setModel:(SJVideoPlayerMoreSettingTwoSetting *)model {
    _model = model;
    
    NSAttributedString *attr = [NSAttributedString mh_imageTextWithImage:model.image imageW:model.image.size.width imageH:model.image.size.height title:model.title ? model.title : @"" fontSize:[SJVideoPlayerMoreSetting titleFontSize] titleColor:[SJVideoPlayerMoreSetting titleColor] spacing:6];
    [_itemBtn setAttributedTitle:attr forState:UIControlStateNormal];
}

- (void)_SJVideoPlayerMoreSettingTwoSettingsCellSetupUI {
    [self.contentView addSubview:self.itemBtn];
    [_itemBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
}

- (UIButton *)itemBtn {
    if ( _itemBtn ) return _itemBtn;
    _itemBtn = [UIButton buttonWithImageName:@"" tag:0 target:self sel:@selector(clickedBtn:)];
    _itemBtn.titleLabel.numberOfLines = 3;
    _itemBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    return _itemBtn;
}

@end


#pragma mark -

@interface SJVideoPlayerMoreSettingTwoLevelSettingsHeaderView : UICollectionReusableView
@property (nonatomic, strong, readwrite) SJVideoPlayerMoreSetting *model;
@end

@interface SJVideoPlayerMoreSettingTwoLevelSettingsHeaderView ()
@property (nonatomic, strong, readonly) SJBorderlineView *backgroundView;
@property (nonatomic, strong, readonly) UILabel *titleLabel;
@end

@implementation SJVideoPlayerMoreSettingTwoLevelSettingsHeaderView

@synthesize backgroundView = _backgroundView;
@synthesize titleLabel = _titleLabel;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _SJVideoPlayerMoreSettingTwoLevelSettingsHeaderViewSetupUI];
    return self;
}


- (void)setModel:(SJVideoPlayerMoreSetting *)model {
    _model = model;
    self.titleLabel.text = model.twoSettingTopTitle;
}

- (void)_SJVideoPlayerMoreSettingTwoLevelSettingsHeaderViewSetupUI {
    [self addSubview:self.backgroundView];
    [self.backgroundView addSubview:self.titleLabel];
    
    [_backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.offset(15);
        make.trailing.offset(-8);
        make.top.bottom.offset(0);
    }];
}

- (SJBorderlineView *)backgroundView {
    if ( _backgroundView ) return _backgroundView;
    _backgroundView = [SJBorderlineView borderlineViewWithSide:SJBorderlineSideBottom startMargin:15 endMargin:0 lineColor:[UIColor lightGrayColor] backgroundColor:[UIColor clearColor]];
    return _backgroundView;
}

- (UILabel *)titleLabel {
    if ( _titleLabel ) return _titleLabel;
    _titleLabel = [UILabel labelWithFontSize:[SJVideoPlayerMoreSettingTwoSetting topTitleFontSize] textColor:[SJVideoPlayerMoreSettingTwoSetting titleColor] alignment:NSTextAlignmentLeft];
    return _titleLabel;
}

@end


#pragma mark -


@interface SJVideoPlayerMoreSettingTwoLevelSettingsView : UIView
@property (nonatomic, strong, readwrite) SJVideoPlayerMoreSetting *twoLevelSettings;
@end

@interface SJVideoPlayerMoreSettingTwoLevelSettingsView (ColDataSourceMethods)<UICollectionViewDataSource>
@end


static NSString *const SJVideoPlayerMoreSettingTwoSettingsCellID = @"SJVideoPlayerMoreSettingTwoSettingsCell";

static NSString *const SJVideoPlayerMoreSettingTwoLevelSettingsHeaderViewID = @"SJVideoPlayerMoreSettingTwoLevelSettingsHeaderView";

@interface SJVideoPlayerMoreSettingTwoLevelSettingsView ()
@property (nonatomic, strong, readonly) UICollectionView *colView;
@property (nonatomic, strong, readwrite) SJVideoPlayerMoreSettingTwoLevelSettingsHeaderView *headerView;
@end

@implementation SJVideoPlayerMoreSettingTwoLevelSettingsView

@synthesize colView = _colView;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _SJVideoPlayerMoreSettingTwoLevelSettingsViewSetupUI];
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

- (void)_SJVideoPlayerMoreSettingTwoLevelSettingsViewSetupUI {
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
    [_colView registerClass:NSClassFromString(SJVideoPlayerMoreSettingTwoSettingsCellID) forCellWithReuseIdentifier:SJVideoPlayerMoreSettingTwoSettingsCellID];
    [_colView registerClass:NSClassFromString(SJVideoPlayerMoreSettingTwoLevelSettingsHeaderViewID) forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:SJVideoPlayerMoreSettingTwoLevelSettingsHeaderViewID];
    _colView.dataSource = self;
    return _colView;
}

@end

@implementation SJVideoPlayerMoreSettingTwoLevelSettingsView (ColDataSourceMethods)

// MARK: UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.twoLevelSettings.twoSettingItems.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:SJVideoPlayerMoreSettingTwoSettingsCellID forIndexPath:indexPath];
    [cell setValue:self.twoLevelSettings.twoSettingItems[indexPath.row] forKey:@"model"];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ( ![kind isEqualToString:UICollectionElementKindSectionHeader] ) return nil;
    self.headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:SJVideoPlayerMoreSettingTwoLevelSettingsHeaderViewID forIndexPath:indexPath];
    self.headerView.model = self.twoLevelSettings;
    return self.headerView;
}

@end




#pragma mark -

static NSString *const SJVideoPlayPreviewColCellID = @"SJVideoPlayPreviewColCell";

@protocol SJVideoPlayPreviewColCellDelegate;

@interface SJVideoPlayPreviewColCell : UICollectionViewCell
@property (nonatomic, strong, readwrite) SJVideoPreviewModel *model;
@property (nonatomic, weak) id <SJVideoPlayPreviewColCellDelegate> delegate;
@end

@protocol SJVideoPlayPreviewColCellDelegate <NSObject>
@optional
- (void)clickedItemOnCell:(SJVideoPlayPreviewColCell *)cell;
@end


@interface SJVideoPlayerControlView (PreviewCellDelegateMethods)<SJVideoPlayPreviewColCellDelegate>@end

@interface SJVideoPlayerControlView (ColDataSourceMethods)<UICollectionViewDataSource>@end


@interface SJVideoPlayPreviewColCell ()
@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, strong, readonly) UIButton *backgroundBtn;
@end

@implementation SJVideoPlayPreviewColCell

@synthesize imageView = _imageView;
@synthesize backgroundBtn = _backgroundBtn;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _SJVideoPlayPreviewColCellSetupUI];
    return self;
}

- (void)setModel:(SJVideoPreviewModel *)model {
    _model = model;
    _imageView.image = model.image;
}

- (void)clickedBtn:(UIButton *)btn {
    if ( ![self.delegate respondsToSelector:@selector(clickedItemOnCell:)] ) return;
    [self.delegate clickedItemOnCell:self];
}

- (void)_SJVideoPlayPreviewColCellSetupUI {
    [self.contentView addSubview:self.backgroundBtn];
    [self.contentView addSubview:self.imageView];
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.offset(0);
        make.top.offset(2);
        make.bottom.offset(-2);
    }];
    [_backgroundBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
}

- (UIImageView *)imageView {
    if ( _imageView ) return _imageView;
    _imageView = [UIImageView imageViewWithImageStr:@"" viewMode:UIViewContentModeScaleAspectFit];
    return _imageView;
}

- (UIButton *)backgroundBtn {
    if ( _backgroundBtn ) return _backgroundBtn;
    _backgroundBtn = [UIButton buttonWithImageName:@"" tag:0 target:self sel:@selector(clickedBtn:)];
    return _backgroundBtn;
}

@end


@implementation SJVideoPlayerControlView (ColDataSourceMethods)

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.previewImages.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:SJVideoPlayPreviewColCellID forIndexPath:indexPath];
    [cell setValue:self.previewImages[indexPath.row] forKey:@"model"];
    [cell setValue:self forKey:@"delegate"];
    return cell;
}

@end


@implementation SJVideoPlayerControlView (PreviewCellDelegateMethods)

- (void)clickedItemOnCell:(SJVideoPlayPreviewColCell *)cell {
    if ( ![self.delegate respondsToSelector:@selector(controlView:selectedPreviewModel:)] ) return;
    SJVideoPreviewModel *model = cell.model;
    [self.delegate controlView:self selectedPreviewModel:model];
}

@end




// MARK: Preview Model

@interface SJVideoPreviewModel ()

@property (nonatomic, strong, readwrite) UIImage *image;
@property (nonatomic, assign, readwrite) CMTime localTime;

@end

@implementation SJVideoPreviewModel

+ (instancetype)previewModelWithImage:(UIImage *)image localTime:(CMTime)time {
    SJVideoPreviewModel *model = [self new];
    model.image = image;
    model.localTime = time;
    return model;
}

@end












#pragma mark -

@interface SJVideoPlayerControlView (DBNotifications)

- (void)_SJVideoPlayerControlViewInstallNotifications;

- (void)_SJVideoPlayerControlViewRemoveNotifications;

@end



#pragma mark -

@interface SJVideoPlayerControlView ()<UIGestureRecognizerDelegate>

// MARK: ...
@property (nonatomic, strong, readonly) SJMaskView *topContainerView;
@property (nonatomic, strong, readonly) UIButton *backBtn;
@property (nonatomic, strong, readonly) UIButton *previewBtn;
@property (nonatomic, strong, readonly) UICollectionView *previewImgColView;
@property (nonatomic, strong, readonly) UIButton *moreBtn;
@property (nonatomic, strong, readonly) SJVideoPlayerMoreSettingsView *moreSettingsView;
@property (nonatomic, strong, readonly) SJVideoPlayerMoreSettingTwoLevelSettingsView *moreSettingsTwoLevelView;


// MARK: ...
@property (nonatomic, strong, readonly) UIButton *replayBtn;
@property (nonatomic, strong, readonly) UIView *lockBtnContainerView;
@property (nonatomic, strong, readonly) UIButton *unlockBtn;
@property (nonatomic, strong, readonly) UIButton *lockBtn;


// MARK: ...
@property (nonatomic, strong, readonly) SJMaskView *bottomContainerView;
@property (nonatomic, strong, readonly) UIButton *playBtn;
@property (nonatomic, strong, readonly) UIButton *pauseBtn;
@property (nonatomic, strong, readonly) UIButton *fullBtn;
@property (nonatomic, strong, readonly) UILabel *currentTimeLabel;
@property (nonatomic, strong, readonly) UILabel *separateLabel;
@property (nonatomic, strong, readonly) UILabel *durationTimeLabel;


// MARK: ...
@property (nonatomic, strong, readonly) UIButton *loadFailedBtn;

// MARK: ...
@property (nonatomic, strong, readonly) SJSlider *bottomProgressView;

// MARK: ...
@property (nonatomic, strong, readonly) JDradualLoadingView *loadingView;


@end

@implementation SJVideoPlayerControlView

// MARK: ...
@synthesize topContainerView = _topContainerView;
@synthesize backBtn = _backBtn;
@synthesize previewBtn = _previewBtn;
@synthesize previewImgColView = _previewImgColView;
@synthesize moreBtn = _moreBtn;
@synthesize moreSettingsView = _moreSettingsView;
@synthesize moreSettingsTwoLevelView = _moreSettingsTwoLevelView;

// MARK: ...
@synthesize replayBtn = _replayBtn;
@synthesize lockBtnContainerView = _lockBtnContainerView;
@synthesize unlockBtn = _unlockBtn;
@synthesize lockBtn = _lockBtn;

// MARK: ...
@synthesize bottomContainerView = _bottomContainerView;
@synthesize playBtn = _playBtn;
@synthesize pauseBtn = _pauseBtn;
@synthesize fullBtn = _fullBtn;
@synthesize currentTimeLabel = _currentTimeLabel;
@synthesize separateLabel = _separateLabel;
@synthesize durationTimeLabel = _durationTimeLabel;
@synthesize sliderControl = _sliderControl;

// MARK: ...
@synthesize draggingTimeLabel = _draggingTimeLabel;
@synthesize draggingProgressView = _draggingProgressView;

// MARK: ...
@synthesize loadFailedBtn = _loadFailedBtn;

// MARK: ...
@synthesize bottomProgressView = _bottomProgressView;

// MARK: ...
@synthesize loadingView = _loadingView;


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _SJVideoPlayerControlViewSetupUI];
    [self _SJVideoPlayerControlViewInstallNotifications];
    return self;
}

- (void)dealloc {
    [self _SJVideoPlayerControlViewRemoveNotifications];
}

// MARK: Actions

- (void)clickedBtn:(UIButton *)btn {
    if ( ![self.delegate respondsToSelector:@selector(controlView:clickedBtnTag:)] ) return;
    [self.delegate controlView:self clickedBtnTag:btn.tag];
}

// MARK: Anima

- (void)previewImgColView_ShowAnima {
    [UIView animateWithDuration:0.3 animations:^{
        self.previewImgColView.transform = CGAffineTransformIdentity;
        self.previewImgColView.alpha = 1.0;
    }];
}

- (void)previewImgColView_HiddenAnima {
    [UIView animateWithDuration:0.3 animations:^{
        self.previewImgColView.transform = CGAffineTransformMakeScale(1, 0.001);
        self.previewImgColView.alpha = 0.001;
    }];
}

- (void)showController {
    [UIView animateWithDuration:0.3 animations:^{
        self.topContainerView.transform = CGAffineTransformIdentity;
        self.bottomContainerView.transform = CGAffineTransformIdentity;
        self.topContainerView.alpha = 1;
        self.bottomContainerView.alpha = 1;
    }];
}

- (void)hiddenController {
    [UIView animateWithDuration:0.3 animations:^{
        self.topContainerView.transform = CGAffineTransformMakeTranslation(0, -SJContainerH);
        self.bottomContainerView.transform = CGAffineTransformMakeTranslation(0, SJContainerH);
        self.topContainerView.alpha = 0.001;
        self.bottomContainerView.alpha = 0.001;
    }];
}


- (void)_showMoreSettringsView {
    [UIView animateWithDuration:0.25 animations:^{
        _moreSettingsView.transform = CGAffineTransformIdentity;
    }];
}

- (void)_hiddenMoreSettingsView {
    [UIView animateWithDuration:0.25 animations:^{
        _moreSettingsView.transform = CGAffineTransformMakeTranslation(SJMoreSettings_W, 0);
    }];
}

- (void)_showMoreSettringsTwoLevelView {
    [UIView animateWithDuration:0.3 animations:^{
        _moreSettingsTwoLevelView.transform = CGAffineTransformIdentity;
    }];
}

- (void)_hiddenMoreSettingsTwoLevelView {
    [UIView animateWithDuration:0.25 animations:^{
        _moreSettingsTwoLevelView.transform = CGAffineTransformMakeTranslation(SJMoreSettings_W, 0);
    }];
}

// MARK: Setter

- (void)setMoreSettings:(NSArray<SJVideoPlayerMoreSetting *> *)moreSettings {
    _moreSettings = moreSettings;
    self.moreSettingsView.moreSettings = moreSettings;
}

- (void)setTwoLevelSettings:(SJVideoPlayerMoreSettingTwoSetting *)twoLevelSettings {
    _twoLevelSettings = twoLevelSettings;
    self.moreSettingsTwoLevelView.twoLevelSettings = twoLevelSettings;
}

// MARK: Public

- (void)startLoading {
    [self addSubview:self.loadingView];
    [_loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
        make.height.equalTo(_loadingView.superview).multipliedBy(0.2);
        make.width.equalTo(_loadingView.mas_height);
    }];
    [self.loadingView startAnimation];
}

- (void)stopLoading {
    [self.loadingView stopAnimation];
    [self.loadingView removeFromSuperview];
}

// MARK: UI

- (void)_SJVideoPlayerControlViewSetupUI {
    
    self.clipsToBounds = YES;
    
    // MARK: ...
    [self addSubview:self.topContainerView];
    [_topContainerView addSubview:self.backBtn];
    [_topContainerView addSubview:self.previewBtn];
    [_topContainerView addSubview:self.moreBtn];
    
    [self addSubview:self.previewImgColView];
    
    [_previewImgColView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.offset(SJPreViewImgH);
        make.leading.trailing.offset(0);
        make.top.equalTo(_topContainerView.mas_bottom);
    }];
    
    [_topContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.offset(0);
        make.height.offset(SJContainerH);
    }];
    
    [_backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.bottom.offset(0);
        make.width.equalTo(_backBtn.mas_height);
    }];
    
    [_previewBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.offset(0);
        make.trailing.equalTo(_moreBtn.mas_leading);
        make.width.equalTo(_previewBtn.mas_height);
    }];
    
    [_moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.offset(0);
        make.trailing.offset(0);
        make.width.equalTo(_moreBtn.mas_height);
    }];
    
    
    
    // MARK: ...
    [self addSubview:self.replayBtn];
    [self addSubview:self.lockBtnContainerView];
    [self.lockBtnContainerView addSubview:self.lockBtn];
    [self.lockBtnContainerView addSubview:self.unlockBtn];
    
    [_lockBtnContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.offset(0);
        make.width.height.offset(44);
        make.centerY.equalTo(_lockBtnContainerView.superview);
    }];
    
    [_lockBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    [_unlockBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    [_replayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
    }];
    
    
    
    // MARK: ...
    [self addSubview:self.bottomContainerView];
    [_bottomContainerView addSubview:self.fullBtn];
    [_bottomContainerView addSubview:self.playBtn];
    [_bottomContainerView addSubview:self.pauseBtn];
    [_bottomContainerView addSubview:self.currentTimeLabel];
    [_bottomContainerView addSubview:self.separateLabel];
    [_bottomContainerView addSubview:self.durationTimeLabel];
    [_bottomContainerView addSubview:self.sliderControl];
    
    [_bottomContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.trailing.offset(0);
        make.height.offset(SJContainerH);
    }];
    
    [_playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.bottom.offset(0);
        make.width.equalTo(_playBtn.mas_height);
    }];
    
    [_pauseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_playBtn);
    }];
    
    [_fullBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.trailing.bottom.offset(0);
        make.width.equalTo(_fullBtn.mas_height);
    }];
    
    [_currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_separateLabel);
        make.leading.equalTo(_playBtn.mas_trailing);
    }];
    
    [_separateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_separateLabel.superview);
        make.leading.equalTo(_currentTimeLabel.mas_trailing);
    }];
    
    [_durationTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_separateLabel.mas_trailing);
        make.centerY.equalTo(_separateLabel);
    }];
    
    [_sliderControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_playBtn.mas_trailing).offset(90);
        make.trailing.equalTo(_fullBtn.mas_leading).offset(-8);
        make.top.bottom.offset(0);
    }];
    
    
    // MARK: ...
    [self addSubview:self.draggingTimeLabel];
    [self addSubview:self.draggingProgressView];
    
    _draggingTimeLabel.text = @"00:00";
    [_draggingTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_draggingTimeLabel.superview);
        make.bottom.equalTo(_draggingTimeLabel.superview.mas_centerY).offset(-8);
    }];
    
    [_draggingProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(130);
        make.height.offset(3);
        make.center.offset(0);
    }];
    
    
    // MARK: ...
    [self addSubview:self.loadFailedBtn];
    [_loadFailedBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
    }];
    
    // MARK: ...
    [self addSubview:self.bottomProgressView];
    [_bottomProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.offset(0);
        make.leading.offset(-1);
        make.trailing.offset(1);
        make.height.offset(1);
    }];
    
    
    [self addSubview:self.moreSettingsView];
    [_moreSettingsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.trailing.bottom.offset(0);
        make.width.offset(SJMoreSettings_W);
    }];
    
    self.hiddenMoreSettingsView = YES;
    
    [self addSubview:self.moreSettingsTwoLevelView];
    [_moreSettingsTwoLevelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.trailing.bottom.offset(0);
        make.width.offset(SJMoreSettings_W);
    }];
    
    self.hiddenMoreSettingsTwoLevelView = YES;
    
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGR:)];
    pan.delegate = self;
    [self.previewImgColView addGestureRecognizer:pan];
}

- (void)handlePanGR:(UIPanGestureRecognizer *)pan {}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(nonnull UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

// MARK: ...

- (UIView *)topContainerView {
    if ( _topContainerView ) return _topContainerView;
    _topContainerView = [[SJMaskView alloc] initWithStyle:SJMaskStyle_top];
    return _topContainerView;
}

- (UIButton *)backBtn {
    if ( _backBtn ) return _backBtn;
    _backBtn = [UIButton buttonWithImageName:SJGetFileWithName(@"sj_video_player_back") tag:SJVideoPlayControlViewTag_Back target:self sel:@selector(clickedBtn:)];
    return _backBtn;
}

- (UIButton *)previewBtn {
    if ( _previewBtn ) return _previewBtn;
    _previewBtn = [UIButton buttonWithTitle:@"预览" backgroundColor:[UIColor clearColor] tag:SJVideoPlayControlViewTag_Preview target:self sel:@selector(clickedBtn:) fontSize:14];
    return _previewBtn;
}

- (UICollectionView *)previewImgColView {
    if ( _previewImgColView ) return _previewImgColView;
    _previewImgColView = [UICollectionView collectionViewWithItemSize:CGSizeMake(SJPreviewImgW, SJPreViewImgH) backgroundColor:[UIColor colorWithWhite:0 alpha:0.42] scrollDirection:UICollectionViewScrollDirectionHorizontal];
    _previewImgColView.dataSource = self;
    [_previewImgColView registerClass:NSClassFromString(SJVideoPlayPreviewColCellID) forCellWithReuseIdentifier:SJVideoPlayPreviewColCellID];
    _previewImgColView.transform = CGAffineTransformMakeScale(1, 0.001);
    _previewImgColView.alpha = 0.001;
    return _previewImgColView;
}

- (UIButton *)moreBtn {
    if ( _moreBtn ) return _moreBtn;
    _moreBtn = [UIButton buttonWithImageName:SJGetFileWithName(@"sj_video_player_more") tag:SJVideoPlayControlViewTag_More target:self sel:@selector(clickedBtn:)];
    return _moreBtn;
}

- (SJVideoPlayerMoreSettingsView *)moreSettingsView {
    if ( _moreSettingsView ) return _moreSettingsView;
    _moreSettingsView = [SJVideoPlayerMoreSettingsView new];
    return _moreSettingsView;
}

- (SJVideoPlayerMoreSettingTwoLevelSettingsView *)moreSettingsTwoLevelView {
    if ( _moreSettingsTwoLevelView ) return _moreSettingsTwoLevelView;
    _moreSettingsTwoLevelView = [SJVideoPlayerMoreSettingTwoLevelSettingsView new];
    return _moreSettingsTwoLevelView;
}

// MARK: ...

- (UIButton *)replayBtn {
    if ( _replayBtn ) return _replayBtn;
    _replayBtn = [UIButton buttonWithTitle:@"" backgroundColor:[UIColor clearColor] tag:SJVideoPlayControlViewTag_Replay target:self sel:@selector(clickedBtn:) fontSize:16];
    _replayBtn.titleLabel.numberOfLines = 3;
    _replayBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    NSAttributedString *attr = [NSAttributedString mh_imageTextWithImage:[UIImage imageNamed:SJGetFileWithName(@"sj_video_player_replay")] imageW:35 imageH:32 title:@"重播" fontSize:16 titleColor:[UIColor whiteColor] spacing:6];
    [_replayBtn setAttributedTitle:attr forState:UIControlStateNormal];
    return _replayBtn;
}

- (UIView *)lockBtnContainerView {
    if ( _lockBtnContainerView ) return _lockBtnContainerView;
    _lockBtnContainerView = [UIView new];
    _lockBtnContainerView.backgroundColor = [UIColor clearColor];
    return _lockBtnContainerView;
}

- (UIButton *)unlockBtn {
    if ( _unlockBtn ) return _unlockBtn;
    _unlockBtn = [UIButton buttonWithImageName:SJGetFileWithName(@"sj_video_player_unlock") tag:SJVideoPlayControlViewTag_Unlock target:self sel:@selector(clickedBtn:)];
    return _unlockBtn;
}

- (UIButton *)lockBtn {
    if ( _lockBtn ) return _lockBtn;
    _lockBtn = [UIButton buttonWithImageName:SJGetFileWithName(@"sj_video_player_lock") tag:SJVideoPlayControlViewTag_Lock target:self sel:@selector(clickedBtn:)];
    return _lockBtn;
}

// MARK: ...

- (SJMaskView *)bottomContainerView {
    if ( _bottomContainerView ) return _bottomContainerView;
    _bottomContainerView = [[SJMaskView alloc] initWithStyle:SJMaskStyle_bottom];
    return _bottomContainerView;
}

- (UIButton *)playBtn {
    if ( _playBtn ) return _playBtn;
    _playBtn = [UIButton buttonWithImageName:SJGetFileWithName(@"sj_video_player_play") tag:SJVideoPlayControlViewTag_Play target:self sel:@selector(clickedBtn:)];
    return _playBtn;
}

- (UIButton *)pauseBtn {
    if ( _pauseBtn ) return _pauseBtn;
    _pauseBtn = [UIButton buttonWithImageName:SJGetFileWithName(@"sj_video_player_pause") tag:SJVideoPlayControlViewTag_Pause target:self sel:@selector(clickedBtn:)];
    return _pauseBtn;
}

- (UIButton *)fullBtn {
    if ( _fullBtn ) return _fullBtn;
    _fullBtn = [UIButton buttonWithImageName:SJGetFileWithName(@"sj_video_player_fullscreen") tag:SJVideoPlayControlViewTag_Full target:self sel:@selector(clickedBtn:)];
    return _fullBtn;
}

- (UILabel *)currentTimeLabel {
    if ( _currentTimeLabel ) return _currentTimeLabel;
    _currentTimeLabel = [UILabel labelWithFontSize:12 textColor:[UIColor whiteColor] alignment:NSTextAlignmentCenter];
    _currentTimeLabel.text = @"00:00";
    return _currentTimeLabel;
}

- (UILabel *)separateLabel {
    if ( _separateLabel ) return _separateLabel;
    _separateLabel = [UILabel labelWithFontSize:12 textColor:[UIColor whiteColor] alignment:NSTextAlignmentCenter];
    _separateLabel.text = @"/";
    return _separateLabel;
}

- (UILabel *)durationTimeLabel {
    if ( _durationTimeLabel ) return _durationTimeLabel;
    _durationTimeLabel = [UILabel labelWithFontSize:12 textColor:[UIColor whiteColor] alignment:NSTextAlignmentCenter];
    _durationTimeLabel.text = @"00:00";
    return _durationTimeLabel;
}

- (SJSlider *)sliderControl {
    if ( _sliderControl ) return _sliderControl;
    _sliderControl = [SJSlider new];
    _sliderControl.tag = SJVideoPlaySliderTag_Control;
    _sliderControl.trackHeight = 2;
    _sliderControl.enableBufferProgress = YES;
    _sliderControl.borderColor = [UIColor clearColor];
    _sliderControl.trackImageView.backgroundColor = [UIColor grayColor];
    _sliderControl.bufferProgressColor = [UIColor whiteColor];
    return _sliderControl;
}

- (SJSlider *)draggingProgressView {
    if ( _draggingProgressView ) return _draggingProgressView;
    _draggingProgressView = [SJSlider new];
    _draggingProgressView.trackHeight = 3;
    _draggingProgressView.trackImageView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    _draggingProgressView.pan.enabled = NO;
    _draggingProgressView.tag = SJVideoPlaySliderTag_Dragging;
    return _draggingProgressView;
}

- (UILabel *)draggingTimeLabel {
    if ( _draggingTimeLabel ) return _draggingTimeLabel;
    _draggingTimeLabel = [UILabel labelWithFontSize:60 textColor:[UIColor whiteColor] alignment:NSTextAlignmentCenter];
    return _draggingTimeLabel;
}


// MARK: ...
- (UIButton *)loadFailedBtn {
    if ( _loadFailedBtn ) return _loadFailedBtn;
    _loadFailedBtn = [UIButton buttonWithTitle:@"加载失败,点击重试" backgroundColor:[UIColor clearColor] tag:SJVideoPlayControlViewTag_LoadFailed target:self sel:@selector(clickedBtn:) fontSize:14];
    return _loadFailedBtn;
}


// MARK: ...
- (SJSlider *)bottomProgressView {
    if ( _bottomProgressView  ) return _bottomProgressView;
    _bottomProgressView = [SJSlider new];
    _bottomProgressView.alpha = 0.001;
    _bottomProgressView.trackImageView.backgroundColor = [UIColor clearColor];
    _bottomProgressView.borderColor = [UIColor clearColor];
    _bottomProgressView.traceImageView.backgroundColor = [UIColor whiteColor];
    _bottomProgressView.trackHeight = 1;
    _bottomProgressView.pan.enabled = NO;
    return _bottomProgressView;
}

// MARK: ...
- (JDradualLoadingView *)loadingView {
    if ( _loadingView ) return _loadingView;
    _loadingView = [JDradualLoadingView new];
    _loadingView.lineWidth = 0.6;
    _loadingView.lineColor = [UIColor whiteColor];
    return _loadingView;
}
@end




// MARK: Control View 通知处理

@implementation SJVideoPlayerControlView (DBNotifications)

- (void)_SJVideoPlayerControlViewInstallNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsPlayerNotification:) name:SJSettingsPlayerNotification object:nil];
}

- (void)_SJVideoPlayerControlViewRemoveNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)settingsPlayerNotification:(NSNotification *)notifi {
    SJVideoPlayerSettings *settings = notifi.object;
    if ( settings.backBtnImage ) [self.backBtn setImage:settings.backBtnImage forState:UIControlStateNormal];
    if ( settings.playBtnImage ) [self.playBtn setImage:settings.playBtnImage forState:UIControlStateNormal];
    if ( settings.pauseBtnImage ) [self.pauseBtn setImage:settings.pauseBtnImage forState:UIControlStateNormal];
    if ( settings.fullBtnImage ) [self.fullBtn setImage:settings.fullBtnImage forState:UIControlStateNormal];
    if ( settings.previewBtnImage ) [self.previewBtn setImage:settings.previewBtnImage forState:UIControlStateNormal];
    if ( settings.moreBtnImage ) [self.moreBtn setImage:settings.moreBtnImage forState:UIControlStateNormal];
    if ( settings.lockBtnImage ) [self.lockBtn setImage:settings.lockBtnImage forState:UIControlStateNormal];
    if ( settings.unlockBtnImage ) [self.unlockBtn setImage:settings.unlockBtnImage forState:UIControlStateNormal];
    if ( settings.traceColor ) {
        self.sliderControl.traceImageView.backgroundColor = settings.traceColor;
        self.draggingProgressView.traceImageView.backgroundColor = settings.traceColor;
        self.bottomProgressView.traceImageView.backgroundColor = settings.traceColor;
    }
    if ( settings.trackColor ) {
        self.sliderControl.trackImageView.backgroundColor = settings.trackColor;
        self.draggingProgressView.trackImageView.backgroundColor = settings.trackColor;
        self.bottomProgressView.trackImageView.backgroundColor = settings.trackColor;
    }
    if ( settings.bufferColor ) self.sliderControl.bufferProgressColor = settings.bufferColor;
    
    if ( settings.replayBtnTitle || settings.replayBtnImage ) {
        UIImage *image = settings.replayBtnImage ? settings.replayBtnImage : [UIImage imageNamed:SJGetFileWithName(@"sj_video_player_replay")];
        NSString *title = settings.replayBtnTitle ? settings.replayBtnTitle : @"重播";
        float fontSize = 0 != settings.replayBtnFontSize ? settings.replayBtnFontSize : 16;
        NSAttributedString *attr = [NSAttributedString mh_imageTextWithImage:image imageW:image.size.width imageH:image.size.height title:title fontSize:fontSize titleColor:[UIColor whiteColor] spacing:6];
        [self.replayBtn setAttributedTitle:attr forState:UIControlStateNormal];
    }
    if ( settings.loadingLineColor ) self.loadingView.lineColor = settings.loadingLineColor;
    if ( 0 != settings.loadingLineWidth ) self.loadingView.lineWidth = settings.loadingLineWidth;
}

@end







@implementation SJVideoPlayerControlView (HiddenOrShow)

/*!
 *  default is NO
 */
- (void)setHiddenBackBtn:(BOOL)hiddenBackBtn {
    if ( hiddenBackBtn == self.hiddenBackBtn ) return;
    objc_setAssociatedObject(self, @selector(hiddenBackBtn), @(hiddenBackBtn), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if ( hiddenBackBtn ) _backBtn.alpha = 0.001;
    else _backBtn.alpha = 1;
}

- (BOOL)hiddenBackBtn {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

/*!
 *  default is NO
 */
- (void)setHiddenPlayBtn:(BOOL)hiddenPlayBtn {
    if ( hiddenPlayBtn == self.hiddenPlayBtn ) return;
    objc_setAssociatedObject(self, @selector(hiddenPlayBtn), @(hiddenPlayBtn), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self hiddenOrShowView:self.playBtn bol:hiddenPlayBtn];
}

- (BOOL)hiddenPlayBtn {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

/*!
 *  default is NO
 */
- (void)setHiddenPauseBtn:(BOOL)hiddenPauseBtn {
    if ( hiddenPauseBtn == self.hiddenPauseBtn ) return;
    objc_setAssociatedObject(self, @selector(hiddenPauseBtn), @(hiddenPauseBtn), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self hiddenOrShowView:self.pauseBtn bol:hiddenPauseBtn];
}

- (BOOL)hiddenPauseBtn {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

/*!
 *  default is NO
 */
- (void)setHiddenReplayBtn:(BOOL)hiddenReplayBtn {
    if ( hiddenReplayBtn == self.hiddenReplayBtn ) return;
    objc_setAssociatedObject(self, @selector(hiddenReplayBtn), @(hiddenReplayBtn), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self hiddenOrShowView:self.replayBtn bol:hiddenReplayBtn];
}

- (BOOL)hiddenReplayBtn {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

/*!
 *  default is NO
 */
- (void)setHiddenPreviewBtn:(BOOL)hiddenPreviewBtn {
    if ( hiddenPreviewBtn == self.hiddenPreviewBtn ) return;
    objc_setAssociatedObject(self, @selector(hiddenPreviewBtn), @(hiddenPreviewBtn), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self hiddenOrShowView:self.previewBtn bol:hiddenPreviewBtn];
    if ( hiddenPreviewBtn ) [self hiddenOrShowView:self.previewImgColView bol:hiddenPreviewBtn];
}

- (BOOL)hiddenPreviewBtn {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

/*!
 *  default is NO
 */
- (void)setHiddenPreview:(BOOL)hiddenPreview {
    if ( hiddenPreview == self.hiddenPreview ) return;
    objc_setAssociatedObject(self, @selector(hiddenPreview), @(hiddenPreview), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if ( hiddenPreview ) [self previewImgColView_HiddenAnima];
    else [self previewImgColView_ShowAnima];
}

- (BOOL)hiddenPreview {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}


/*!
 *  default is NO
 */
- (void)setHiddenLockBtn:(BOOL)hiddenLockBtn {
    if ( hiddenLockBtn == self.hiddenLockBtn ) return;
    objc_setAssociatedObject(self, @selector(hiddenLockBtn), @(hiddenLockBtn), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self hiddenOrShowView:self.lockBtn bol:hiddenLockBtn];
    
}

- (BOOL)hiddenLockBtn {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

/*!
 *  default is NO
 */
- (void)setHiddenLockContainerView:(BOOL)hiddenLockContainerView {
    if ( hiddenLockContainerView == self.hiddenLockContainerView ) return;
    objc_setAssociatedObject(self, @selector(hiddenLockContainerView), @(hiddenLockContainerView), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGFloat alpha = 1;
    if ( hiddenLockContainerView ) {
        transform = CGAffineTransformMakeTranslation(-100, 0);
        alpha = 0.001;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        self.lockBtnContainerView.transform = transform;
        self.lockBtnContainerView.alpha = alpha;
    }];
}

- (BOOL)hiddenLockContainerView {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

/*!
 *  default is NO
 */
- (void)setHiddenControl:(BOOL)hiddenControl {
    if ( hiddenControl == self.hiddenControl ) return;
    objc_setAssociatedObject(self, @selector(hiddenControl), @(hiddenControl), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if ( hiddenControl ) [self hiddenController];
    else [self showController];
}

- (BOOL)hiddenControl {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

/*!
 *  default is NO
 */
- (void)setHiddenLoadFailedBtn:(BOOL)hiddenLoadFailedBtn {
    if ( hiddenLoadFailedBtn == self.hiddenLoadFailedBtn ) return;
    objc_setAssociatedObject(self, @selector(hiddenLoadFailedBtn), @(hiddenLoadFailedBtn), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self hiddenOrShowView:self.loadFailedBtn bol:hiddenLoadFailedBtn];
}

- (BOOL)hiddenLoadFailedBtn {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

/*!
 *  default is NO
 */
- (void)setHiddenBottomProgressView:(BOOL)hiddenBottomProgressView {
    if ( hiddenBottomProgressView == self.hiddenBottomProgressView ) return;
    objc_setAssociatedObject(self, @selector(hiddenBottomProgressView), @(hiddenBottomProgressView), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self hiddenOrShowView:self.bottomProgressView bol:hiddenBottomProgressView];
}

- (BOOL)hiddenBottomProgressView {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

/*!
 *  default is NO
 */
- (void)setHiddenUnlockBtn:(BOOL)hiddenUnlockBtn {
    if ( hiddenUnlockBtn == self.hiddenUnlockBtn ) return;
    objc_setAssociatedObject(self, @selector(hiddenUnlockBtn), @(hiddenUnlockBtn), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self hiddenOrShowView:self.unlockBtn bol:hiddenUnlockBtn];
}

- (BOOL)hiddenUnlockBtn  {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

/*!
 *  default is NO
 */
- (void)setHiddenMoreBtn:(BOOL)hiddenMoreBtn {
    if ( hiddenMoreBtn == self.hiddenMoreBtn ) return;
    objc_setAssociatedObject(self, @selector(hiddenMoreBtn), @(hiddenMoreBtn), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self hiddenOrShowView:self.moreBtn bol:hiddenMoreBtn];
}

- (BOOL)hiddenMoreBtn {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

/*!
 *  default is YES
 */
- (void)setHiddenMoreSettingsView:(BOOL)hiddenMoreSettingsView {
    if ( hiddenMoreSettingsView == self.hiddenMoreSettingsView ) return;
    objc_setAssociatedObject(self, @selector(hiddenMoreSettingsView), @(hiddenMoreSettingsView), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if ( hiddenMoreSettingsView ) [self _hiddenMoreSettingsView];
    else [self _showMoreSettringsView];
}

- (BOOL)hiddenMoreSettingsView {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

/*!
 *  default is YES
 */
- (void)setHiddenMoreSettingsTwoLevelView:(BOOL)hiddenMoreSettingsTwoLevelView {
    if ( hiddenMoreSettingsTwoLevelView == self.hiddenMoreSettingsTwoLevelView ) return;
    objc_setAssociatedObject(self, @selector(hiddenMoreSettingsTwoLevelView), @(hiddenMoreSettingsTwoLevelView), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if ( hiddenMoreSettingsTwoLevelView ) [self _hiddenMoreSettingsTwoLevelView];
    else [self _showMoreSettringsTwoLevelView];
}

- (BOOL)hiddenMoreSettingsTwoLevelView {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)hiddenOrShowView:(UIView *)view bol:(BOOL)hidden {
    CGFloat alpha = 1.;
    if ( hidden ) alpha = 0.001;
    if ( view.alpha == alpha ) return;
    [UIView animateWithDuration:0.25 animations:^{
        view.alpha = alpha;
    }];
}

/*!
 *  default is NO
 */
- (void)setHiddenDraggingProgress:(BOOL)hiddenDraggingProgress {
    if ( hiddenDraggingProgress == self.hiddenDraggingProgress ) return;
    objc_setAssociatedObject(self, @selector(hiddenDraggingProgress), @(hiddenDraggingProgress), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self hiddenOrShowView:self.draggingTimeLabel bol:hiddenDraggingProgress];
    [self hiddenOrShowView:self.draggingProgressView bol:hiddenDraggingProgress];
}

- (BOOL)hiddenDraggingProgress {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

@end




@implementation SJVideoPlayerControlView (TimeOperation)

- (NSString *)formatSeconds:(NSInteger)value {
    NSInteger seconds = value % 60;
    NSInteger minutes = value / 60;
    return [NSString stringWithFormat:@"%02ld:%02ld", (long) minutes, (long) seconds];
}

- (void)setCurrentTime:(NSTimeInterval)currentTime duration:(NSTimeInterval)duration {
    _currentTimeLabel.text = [self formatSeconds:currentTime];
    _durationTimeLabel.text = [self formatSeconds:duration];
    if ( 0 == duration || isnan(duration) ) return;
    _sliderControl.value = currentTime / duration;
    _bottomProgressView.value = _sliderControl.value;
}

@end




// MARK: More Settings Sliders

@implementation SJVideoPlayerControlView (MoreSettings)

- (SJSlider *)volumeSlider {
    return self.moreSettingsView.footerView.volumeSlider;
}

- (SJSlider *)rateSlider {
    return self.moreSettingsView.footerView.rateSlider;
}

- (SJSlider *)brightnessSlider {
    return self.moreSettingsView.footerView.brightnessSlider;
}

- (void)getMoreSettingsSlider:(void(^)(SJSlider *volumeSlider, SJSlider *brightnessSlider, SJSlider *rateSlider))block {
    [self.moreSettingsView getMoreSettingsSlider:block];
}

@end



// MARK: Preview

@implementation SJVideoPlayerControlView (Preview)

- (void)setPreviewImages:(NSArray<SJVideoPreviewModel *> *)previewImages {
    objc_setAssociatedObject(self, @selector(previewImages), previewImages, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.previewImgColView reloadData];
}

- (NSArray<SJVideoPreviewModel *> *)previewImages {
    return objc_getAssociatedObject(self, _cmd);
}

@end

