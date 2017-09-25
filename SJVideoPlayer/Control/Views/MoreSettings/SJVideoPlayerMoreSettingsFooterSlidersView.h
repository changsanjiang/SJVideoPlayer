//
//  SJVideoPlayerMoreSettingsFooterSlidersView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/9/25.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJSlider;

@interface SJVideoPlayerMoreSettingsFooterSlidersView : UICollectionReusableView

@property (nonatomic, strong, readonly) SJSlider *volumeSlider;
@property (nonatomic, strong, readonly) SJSlider *brightnessSlider;
@property (nonatomic, strong, readonly) SJSlider *rateSlider;

@end
