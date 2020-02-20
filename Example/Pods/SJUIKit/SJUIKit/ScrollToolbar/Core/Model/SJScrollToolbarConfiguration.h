//
//  SJScrollToolbarConfiguration.h
//  SJScrollToolbar
//
//  Created by 畅三江 on 2019/12/24.
//

#import <Foundation/Foundation.h>
#import "SJScrollToolbarDefines.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJScrollToolbarConfiguration : NSObject<SJScrollToolbarConfiguration>
+ (instancetype)configuration;

@property (nonatomic) CGFloat barHeight;
@property (nonatomic) SJScrollToolbarDistribution distribution;
@property (nonatomic) SJScrollToolbarAlignment alignment;
@property (nonatomic) CGFloat spacing;
@property (nonatomic, strong, nullable) UIColor *barTintColor;
@property (nonatomic, strong, nullable) UIColor *itemTintColor;
@property (nonatomic, strong, nullable) UIColor *focusedItemTintColor;
@property (nonatomic, strong, nullable) UIFont *maximumFont;
@property (nonatomic) CGFloat minimumZoomScale;
@property (nonatomic) NSTimeInterval animationDuration;

@property (nonatomic) CGSize lineSize;
@property (nonatomic) CGFloat lineCornerRadius;
@property (nonatomic) CGFloat lineBottomMargin;
@property (nonatomic, strong, nullable) UIColor *lineTintColor;

@end
NS_ASSUME_NONNULL_END
