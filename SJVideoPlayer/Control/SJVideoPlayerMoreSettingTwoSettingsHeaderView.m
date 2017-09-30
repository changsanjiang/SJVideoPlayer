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
#import "SJVideoPlayerMoreSettingTwoSetting.h"

@interface SJVideoPlayerMoreSettingTwoSettingsHeaderView ()

@property (nonatomic, strong, readonly) UIView *line;
@property (nonatomic, strong, readonly) UILabel *titleLabel;

@end

@implementation SJVideoPlayerMoreSettingTwoSettingsHeaderView

@synthesize line = _line;
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
    [self addSubview:self.line];
    [self addSubview:self.titleLabel];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.offset(15);
        make.trailing.offset(-8);
        make.top.bottom.offset(0);
    }];
    
    [_line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_titleLabel);
        make.bottom.trailing.offset(0);
        make.height.offset(1);
    }];
}

- (UIView *)line {
    if ( _line ) return _line;
    _line = [UIView new];
    _line.backgroundColor = [UIColor lightGrayColor];
    return _line;
}

- (UILabel *)titleLabel {
    if ( _titleLabel ) return _titleLabel;
    _titleLabel = [UILabel labelWithFontSize:[SJVideoPlayerMoreSettingTwoSetting topTitleFontSize] textColor:[SJVideoPlayerMoreSettingTwoSetting titleColor] alignment:NSTextAlignmentLeft];
    return _titleLabel;
}

@end
