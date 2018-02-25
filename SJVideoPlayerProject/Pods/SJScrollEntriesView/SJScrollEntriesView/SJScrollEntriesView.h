//
//  SJScrollEntriesView.h
//  SJScrollEntriesViewProject
//
//  Created by BlueDancer on 2017/9/4.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SJScrollEntriesViewUserProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class SJScrollEntriesViewSettings;

@protocol SJScrollEntriesViewDelegate;

@interface SJScrollEntriesView : UIView

- (instancetype)initWithSettings:(SJScrollEntriesViewSettings *__nullable)settings;

@property (nonatomic, assign, readonly) NSInteger currentIndex;
- (void)changeIndex:(NSInteger)index;

@property (nonatomic, strong, readwrite) NSArray<id<SJScrollEntriesViewUserProtocol>> *items;

@property (nonatomic, weak, readwrite) id <SJScrollEntriesViewDelegate> delegate;

@property (nonatomic, strong, readonly) UIScrollView *scrollView;

@property (nonatomic, strong, readonly) NSArray<UIButton *> *itemArr;

@end


@protocol SJScrollEntriesViewDelegate <NSObject>

@optional
- (void)scrollEntriesView:(SJScrollEntriesView *)view currentIndex:(NSInteger)currentIndex beforeIndex:(NSInteger)beforeIndex;

@end




@interface SJScrollEntriesViewSettings : NSObject

+ (instancetype)defaultSettings;

/// default is 14
@property (nonatomic, assign) float fontSize;
/// default is redColor
@property (nonatomic, strong) UIColor *selectedColor;
/// default is blackColor
@property (nonatomic, strong) UIColor *normalColor;
/// default is 1.3
@property (nonatomic, assign) float itemScale;
/// default is red
@property (nonatomic, strong) UIColor *lineColor;
/// default is 2
@property (nonatomic, assign) float lineHeight;
/// defualt is 0.382
@property (nonatomic, assign) float lineScale;
/// default is 32
@property (nonatomic, assign) float itemSpacing;

/*!
 *  default is Screen Width.
 *  如果 所有item的宽度+itemSpacing, 达不到最大宽度时, 将会平均分布.
 **/
@property (nonatomic, assign) float scrollViewMaxWidth;

@end


NS_ASSUME_NONNULL_END

