//
//  SJVideoPlayerMoreSettingsView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/9/25.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJMoreSettingsSlidersViewModel.h"
@class SJVideoPlayerMoreSetting;

NS_ASSUME_NONNULL_BEGIN
@interface SJVideoPlayerMoreSettingsView : UIView
@property (nonatomic, strong, nullable) NSArray<SJVideoPlayerMoreSetting *> *moreSettings;
@property (nonatomic, strong, nullable) SJMoreSettingsSlidersViewModel *footerViewModel;
@property (nonatomic) BOOL fullscreen;
- (void)update;
@end
NS_ASSUME_NONNULL_END
