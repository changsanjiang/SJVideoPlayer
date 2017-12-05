//
//  SJVideoPlayerMoreSettingsFooterSlidersView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/9/25.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJMoreSettingsFooterViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SJVideoPlayerMoreSettingsFooterSlidersView : UICollectionReusableView

@property (nonatomic, weak, readwrite) SJMoreSettingsFooterViewModel *model;

@end

NS_ASSUME_NONNULL_END
