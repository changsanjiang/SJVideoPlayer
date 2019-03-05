//
//  SJVideoPlayerMoreSettingsSecondaryHeaderView.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/12/5.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerMoreSettingsSecondaryHeaderView.h" 
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif
#import "SJVideoPlayerMoreSetting.h"
#import "SJVideoPlayerMoreSettingSecondaryView.h"
#import "SJVideoPlayerMoreSettingSecondary.h"


@interface SJVideoPlayerMoreSettingsSecondaryHeaderView ()

@property (nonatomic, strong, readonly) UIView *line;
@property (nonatomic, strong, readonly) UILabel *titleLabel;

@end

@implementation SJVideoPlayerMoreSettingsSecondaryHeaderView

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
        make.leading.equalTo(self->_titleLabel);
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
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLabel.textColor = [SJVideoPlayerMoreSettingSecondary titleColor];
    _titleLabel.font = [UIFont systemFontOfSize:[SJVideoPlayerMoreSettingSecondary topTitleFontSize]];
    return _titleLabel;
}

@end
