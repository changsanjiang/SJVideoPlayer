//
//  SJButtonItemCollectionViewCell.m
//  SJVideoPlayer
//
//  Created by BlueDancer on 2018/10/20.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import "SJButtonItemCollectionViewCell.h"
#import <Masonry/Masonry.h>

@implementation SJButtonItemCollectionViewCell
static NSString *SJButtonItemCollectionViewCellID = @"SJButtonItemCollectionViewCell";
+ (void)registerWithCollectionView:(UICollectionView *)collectionView {
    [collectionView registerClass:[self class] forCellWithReuseIdentifier:SJButtonItemCollectionViewCellID];
}

+ (instancetype)cellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath {
    return [collectionView dequeueReusableCellWithReuseIdentifier:SJButtonItemCollectionViewCellID forIndexPath:indexPath];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _setupView];
    return self;
}

- (void)_setupView {
    [self.contentView addSubview:self.button];
    [_button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
}

@synthesize button = _button;
- (UIButton *)button {
    if ( _button ) return _button;
    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    _button.titleLabel.numberOfLines = 0;
    return _button;
}
@end
