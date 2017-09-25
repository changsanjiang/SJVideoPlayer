//
//  SJVideoPlayerMoreSettingTwoSettingsHeaderView.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/9/25.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerMoreSettingTwoSettingsHeaderView.h"
#import "NSAttributedString+ZFBAdditon.h"
#import <Masonry/Masonry.h>
#import "UIView+SJExtension.h"
#import "SJVideoPlayerMoreSetting.h"
#import "SJVideoPlayerMoreSettingTwoSettingsView.h"
#import <SJBorderLineView/SJBorderlineView.h>
#import "SJVideoPlayerMoreSettingTwoSetting.h"

@interface SJVideoPlayerMoreSettingTwoSettingsHeaderView ()

@property (nonatomic, strong, readonly) SJBorderlineView *backgroundView;
@property (nonatomic, strong, readonly) UILabel *titleLabel;

@end

@implementation SJVideoPlayerMoreSettingTwoSettingsHeaderView

@synthesize backgroundView = _backgroundView;
@synthesize titleLabel = _titleLabel;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _SJVideoPlayerMoreSettingTwoSettingsHeaderViewSetupUI];
    return self;
}


- (void)setModel:(SJVideoPlayerMoreSetting *)model {
    _model = model;
    self.titleLabel.text = model.twoSettingTopTitle;
}

- (void)_SJVideoPlayerMoreSettingTwoSettingsHeaderViewSetupUI {
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
