//
//  SJVideoPlayerMoreSettingsView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/9/25.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJMoreSettingsSlidersViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@class SJVideoPlayerMoreSetting;

@interface SJVideoPlayerMoreSettingsView : UIView

@property (nonatomic, strong, readwrite, nullable) NSArray<SJVideoPlayerMoreSetting *> *moreSettings;

@property (nonatomic, strong, readwrite, nullable) SJMoreSettingsSlidersViewModel *footerViewModel;

@property (nonatomic) BOOL fullscreen;

@end

NS_ASSUME_NONNULL_END
