//
//  SJVideoPlayerMoreSettingsView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/9/25.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerBaseView.h"
#import "SJMoreSettingsFooterViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@class SJVideoPlayerMoreSettingsFooterSlidersView, SJVideoPlayerMoreSetting, SJSlider, SJOrentationObserver;

@interface SJVideoPlayerMoreSettingsView : SJVideoPlayerBaseView

- (instancetype)initWithOrentationObserver:(__weak SJOrentationObserver *)orentationObserver;

@property (nonatomic, strong, readwrite, nullable) NSArray<SJVideoPlayerMoreSetting *> *moreSettings;

@property (nonatomic, strong, readwrite, nullable) SJMoreSettingsFooterViewModel *footerViewModel;

@end

NS_ASSUME_NONNULL_END
