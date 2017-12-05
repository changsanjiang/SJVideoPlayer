//
//  SJVideoPlayerMoreSettingsView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/9/25.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class SJVideoPlayerMoreSettingsFooterSlidersView, SJVideoPlayerMoreSetting, SJSlider;

@interface SJVideoPlayerMoreSettingsView : UIView

@property (nonatomic, strong, readwrite, nullable) NSArray<SJVideoPlayerMoreSetting *> *moreSettings;

@end

NS_ASSUME_NONNULL_END
