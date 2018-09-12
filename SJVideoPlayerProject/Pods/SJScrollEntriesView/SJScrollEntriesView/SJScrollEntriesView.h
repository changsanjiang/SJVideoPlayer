//
//  SJScrollEntriesView.h
//  SJScrollEntriesViewProject
//
//  Created by BlueDancer on 2017/9/4.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJScrollEntriesViewUserProtocol.h"
@class SJScrollEntriesViewSettings;
@protocol SJScrollEntriesViewDelegate;


NS_ASSUME_NONNULL_BEGIN
@interface SJScrollEntriesView : UIView
- (instancetype)initWithSettings:(nullable SJScrollEntriesViewSettings *)settings;

@property (nonatomic, readonly) NSInteger currentIndex;
- (void)changeIndex:(NSInteger)index;

@property (nonatomic, strong, nullable) NSArray<id<SJScrollEntriesViewUserProtocol>> *items;
@property (nonatomic, weak, nullable) id <SJScrollEntriesViewDelegate> delegate;

@property (nonatomic, strong, readonly, nullable) NSArray<UIButton *> *buttonItemsArr;
@property (nonatomic, strong, readonly) UIScrollView *scrollView;
@end


@protocol SJScrollEntriesViewDelegate <NSObject>
@optional
- (void)scrollEntriesView:(SJScrollEntriesView *)view currentIndex:(NSInteger)currentIndex beforeIndex:(NSInteger)beforeIndex;
@end



@interface SJScrollEntriesViewSettings : NSObject

+ (instancetype)defaultSettings;

/// default is 14
@property (nonatomic) float fontSize;
/// default is redColor
@property (nonatomic, strong) UIColor *selectedColor;
/// default is blackColor
@property (nonatomic, strong) UIColor *normalColor;
/// default is 1.3
@property (nonatomic) float itemScale;
/// default is red
@property (nonatomic, strong) UIColor *lineColor;
/// default is 2
@property (nonatomic) float lineHeight;
/// defualt is 0.382
@property (nonatomic) float lineScale;
/// default is 32
@property (nonatomic) float itemSpacing;

/*!
 *  default is Screen Width.
 *  如果 所有item的宽度+itemSpacing, 达不到最大宽度时, 将会平均分布.
 **/
@property (nonatomic) float scrollViewMaxWidth;

@end
NS_ASSUME_NONNULL_END

