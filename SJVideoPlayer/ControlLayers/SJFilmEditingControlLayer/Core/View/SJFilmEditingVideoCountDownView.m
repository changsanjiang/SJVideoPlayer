//
//  SJFilmEditingVideoCountDownView.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2019/1/20.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import "SJFilmEditingVideoCountDownView.h"
#import "SJFilmEditingCommonViewLayer.h"
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif

NS_ASSUME_NONNULL_BEGIN
@implementation SJFilmEditingVideoCountDownView
+ (Class)layerClass {
    return [SJFilmEditingCommonViewLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _setupViews];
    }
    return self;
}

- (void)_setupViews {
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _timeLabel.font = [UIFont systemFontOfSize:11];
    _timeLabel.textColor = UIColor.whiteColor;
    
    _promptLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _promptLabel.font = [UIFont systemFontOfSize:11];
    _promptLabel.textColor = UIColor.whiteColor;
    
    _progressSlider = [[SJProgressSlider alloc] initWithFrame:CGRectZero];
    _progressSlider.trackHeight = 2;
    _progressSlider.userInteractionEnabled = NO;
    
    [self addSubview:_timeLabel];
    [self addSubview:_promptLabel];
    [self addSubview:_progressSlider];
    
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(5);
        make.left.offset(24);
        make.width.offset(90);
    }];
    
    [_promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.timeLabel.mas_right).offset(40);
        make.top.bottom.equalTo(self.timeLabel);
        make.right.offset(-24);
    }];
    
    [_progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.timeLabel.mas_bottom).offset(5);
        make.left.equalTo(self.timeLabel);
        make.right.equalTo(self.promptLabel);
        make.bottom.mas_greaterThanOrEqualTo(-8);
        make.height.offset(2);
    }];
}
@end
NS_ASSUME_NONNULL_END
