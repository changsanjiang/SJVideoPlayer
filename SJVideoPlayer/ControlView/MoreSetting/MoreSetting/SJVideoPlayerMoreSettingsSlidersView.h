//
//  SJVideoPlayerMoreSettingsSlidersView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/2/5.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJMoreSettingsSlidersViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SJVideoPlayerMoreSettingsSlidersView : UIView

@property (nonatomic, weak, readwrite, nullable) SJMoreSettingsSlidersViewModel *model;

@end

NS_ASSUME_NONNULL_END
