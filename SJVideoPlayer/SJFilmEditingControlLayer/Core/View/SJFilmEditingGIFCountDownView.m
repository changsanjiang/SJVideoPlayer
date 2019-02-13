//
//  SJFilmEditingGIFCountDownView.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2019/1/20.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import "SJFilmEditingGIFCountDownView.h"
#import "SJFilmEditingCommonViewLayer.h"
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif

@implementation SJFilmEditingGIFCountDownView
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
    _timeLabel.font = [UIFont systemFontOfSize:12];
    _timeLabel.textColor = UIColor.whiteColor;
    
    _promptLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _promptLabel.font = [UIFont systemFontOfSize:12];
    _promptLabel.textColor = UIColor.whiteColor;
    
    [self addSubview:_timeLabel];
    [self addSubview:_promptLabel];
    
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(24);
        make.top.bottom.offset(0);
        make.width.offset(20);
    }];
    
    [_promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.timeLabel.mas_right).offset(40);
        make.top.bottom.equalTo(self.timeLabel);
        make.right.offset(-24);
    }];
}
@end
