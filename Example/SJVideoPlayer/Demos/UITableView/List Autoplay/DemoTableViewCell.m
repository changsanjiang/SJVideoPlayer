//
//  DemoTableViewCell.m
//  MJRefreshDemo
//
//  Created by BlueDancer on 2019/5/4.
//  Copyright © 2019 SanJiang. All rights reserved.
//

#import "DemoTableViewCell.h"
#import <Masonry/Masonry.h>

NS_ASSUME_NONNULL_BEGIN
@interface DemoTableViewCell ()
@property (nonatomic, strong, readonly) UILabel *titleLabel;
@property (nonatomic, strong, readonly) UIImageView *coverImageView;
@end

@implementation DemoTableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if ( !self ) return nil;
    [self _setupView];
    [self _addTapGestureToCover];
    return self;
}

- (void)_setupView {
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    _coverImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _coverImageView.backgroundColor = [UIColor colorWithRed:arc4random() % 256 / 255.0
                                                      green:arc4random() % 256 / 255.0
                                                       blue:arc4random() % 256 / 255.0
                                                      alpha:1];
    _coverImageView.userInteractionEnabled = YES;
    _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    _coverImageView.clipsToBounds = YES;
    [self.contentView addSubview:_coverImageView];
    [_coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.offset(0);
        make.height.equalTo(self.contentView.mas_width).multipliedBy(9/16.0);
    }];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [_coverImageView addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.offset(8);
        make.right.offset(-8);
    }];
}

- (void)_addTapGestureToCover {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleTap:)];
    tap.delaysTouchesBegan = YES;
    [_coverImageView addGestureRecognizer:tap];
}

- (void)_handleTap:(UITapGestureRecognizer *)tap {
    if ( [(id)self.delegate respondsToSelector:@selector(demoTableViewCell:clickedOnTheCover:)] ) {
        [self.delegate demoTableViewCell:self clickedOnTheCover:_coverImageView];
    }
}

- (void)setDataSource:(nullable id<DemoTableViewCellDataSoruce>)dataSource {
    if ( dataSource != _dataSource ) {
        _dataSource = dataSource;
        _coverImageView.tag = dataSource.coverTag;
        _titleLabel.text = dataSource.title;
//        _coverImageView.image = [UIImage imageNamed:dataSource.coverURL];
    }
}
@end
NS_ASSUME_NONNULL_END
