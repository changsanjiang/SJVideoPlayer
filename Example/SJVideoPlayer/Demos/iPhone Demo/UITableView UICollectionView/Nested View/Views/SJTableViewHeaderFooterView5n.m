//
//  SJTableViewHeaderFooterView5n.m
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2019/6/26.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import "SJTableViewHeaderFooterView5n.h"
#import <Masonry/Masonry.h>

NS_ASSUME_NONNULL_BEGIN
@interface SJTableViewHeaderFooterView5n ()
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation SJTableViewHeaderFooterView5n
- (instancetype)initWithReuseIdentifier:(nullable NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if ( self ) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont boldSystemFontOfSize:20];
        _titleLabel.textColor = UIColor.blackColor;
        [self.contentView addSubview:_titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.offset(22);
            make.centerY.offset(0);
        }];
    }
    return self;
}

- (void)setTitle:(nullable NSString *)title {
    _titleLabel.text = title;
}
- (nullable NSString *)title {
    return _titleLabel.text;
}
@end
NS_ASSUME_NONNULL_END
