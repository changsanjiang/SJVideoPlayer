//
//  SJCommonSlider.h
//  SJSlider
//
//  Created by BlueDancer on 2017/11/20.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJSlider.h"

@interface SJCommonSlider : UIView

@property (nonatomic, strong, readonly) UIView *leftContainerView;
@property (nonatomic, strong, readonly) SJSlider *slider;
@property (nonatomic, strong, readonly) UIView *rightContainerView;

@end
