//
//  SJScrollToolbarConfiguration.m
//  SJScrollToolbar
//
//  Created by 畅三江 on 2019/12/24.
//

#import "SJScrollToolbarConfiguration.h"

@implementation SJScrollToolbarConfiguration
+ (instancetype)configuration {
    return self.new;
}

- (instancetype)init {
    self = [super init];
    if ( self ) {
        _barHeight = 40;
        _distribution = SJScrollToolbarDistributionEqualSpacing;
        _alignment = SJScrollToolbarAlignmentBottom;
        _spacing = 20;
        _itemTintColor = UIColor.blackColor;
        _focusedItemTintColor = _itemTintColor;
        _barTintColor = UIColor.whiteColor;
        _maximumFont = [UIFont boldSystemFontOfSize:26];
        _minimumZoomScale = 16/26.0;
        _animationDuration = 0.3;
        
        _lineSize = CGSizeMake(20, 3);
        _lineCornerRadius = 1.5;
        _lineBottomMargin = 0;
        _lineTintColor = _itemTintColor;
    }
    return self;
}
@end
