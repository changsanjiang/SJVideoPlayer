//
//  SJFilmEditingButtonContainerView.h
//  SJVideoPlayer
//
//  Created by 畅三江 on 2019/1/20.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJFilmEditingBackButton.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJFilmEditingButtonContainerView : UIView
- (instancetype)initWithFrame:(CGRect)frame buttonSize:(CGSize)size;
@property (nonatomic, strong, readonly) SJFilmEditingBackButton *button;

@property (nonatomic, copy, nullable) void(^clickedBackButtonExeBlock)(SJFilmEditingButtonContainerView *view);
@end
NS_ASSUME_NONNULL_END
