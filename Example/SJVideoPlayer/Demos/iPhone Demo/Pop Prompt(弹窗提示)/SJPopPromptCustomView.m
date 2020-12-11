//
//  SJPopPromptCustomView.m
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2019/10/12.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import "SJPopPromptCustomView.h"
#import <SJUIKit/NSAttributedString+SJMake.h>
#import <Masonry/Masonry.h>

NS_ASSUME_NONNULL_BEGIN
@interface SJPopPromptCustomView ()
@property (nonatomic, strong, readonly) UIButton *removeButton;
@property (nonatomic, strong, readonly) UILabel *label;
@property (nonatomic, strong, readonly) UIButton *jumpButton;
@end

@implementation SJPopPromptCustomView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _setupView];
    return self;
}

- (void)test:(UIButton *)btn {
#ifdef DEBUG
    NSLog(@"%d - %s", (int)__LINE__, __func__);
#endif
    if ( _jumpButton == btn ) {
        if ( _jumpButtonWasTappedExeBlock ) _jumpButtonWasTappedExeBlock(self);
    }
}

- (void)setTime:(nullable NSString *)time {
    _time = time;
    _label.text = [NSString stringWithFormat:@"记忆您上次看到 %@", time];
}

- (void)_setupView {
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    self.layer.cornerRadius = 5;

    _removeButton = [UIButton.alloc initWithFrame:CGRectZero];
    [_removeButton setImage:[UIImage imageNamed:@"remove"] forState:UIControlStateNormal];
    [_removeButton addTarget:self action:@selector(test:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_removeButton];
    
    _label = [UILabel.alloc initWithFrame:CGRectZero];
    _label.text = @"记忆您上次看到01:22";
    _label.font = [UIFont systemFontOfSize:14];
    _label.textColor = UIColor.whiteColor;
    [self addSubview:_label];
    
    _jumpButton = [UIButton.alloc initWithFrame:CGRectZero];
    [_jumpButton setAttributedTitle:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
        make.append(@"跳转播放");
        make.font([UIFont systemFontOfSize:14]);
        make.textColor(UIColor.orangeColor);
    }] forState:UIControlStateNormal];
    [_jumpButton addTarget:self action:@selector(test:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_jumpButton];
    
    
    [_removeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(8);
        make.left.offset(8);
        make.bottom.offset(-8);
        make.size.offset(25);
    }];
    
    [_label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.removeButton.mas_right).offset(8);
        make.centerY.offset(0);
    }];
    
    [_jumpButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.label.mas_right).offset(8);
        make.right.offset(-8);
        make.centerY.offset(0);
    }];
}
@end
NS_ASSUME_NONNULL_END
