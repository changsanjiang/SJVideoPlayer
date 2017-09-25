//
//  SJVideoPlayerMoreSettingsView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/9/25.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJVideoPlayerMoreSettingsFooterSlidersView, SJVideoPlayerMoreSetting, SJSlider;

@interface SJVideoPlayerMoreSettingsView : UIView

@property (nonatomic, strong, readonly) SJVideoPlayerMoreSettingsFooterSlidersView *footerView;
@property (nonatomic, strong, readwrite) NSArray<SJVideoPlayerMoreSetting *> *moreSettings;

- (void)getMoreSettingsSlider:(void (^)(SJSlider *, SJSlider *, SJSlider *))block;

@end
