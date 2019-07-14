//
//  SJMoreSettingControlLayer.h
//  SJVideoPlayer
//
//  Created by BlueDancer on 2018/10/26.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJControlLayerDefines.h"
@class SJVideoPlayerMoreSetting;

@protocol SJMoreSettingControlLayerDelegate;

NS_ASSUME_NONNULL_BEGIN
@interface SJMoreSettingControlLayer : UIView<SJControlLayer>
@property (nonatomic, strong, nullable) NSArray<SJVideoPlayerMoreSetting *> *moreSettings;
@property (nonatomic, weak, nullable) id<SJMoreSettingControlLayerDelegate> delegate;
@end

@protocol SJMoreSettingControlLayerDelegate <NSObject>
- (void)tappedOnTheBlankAreaOfControlLayer:(id<SJControlLayer>)controlLayer;
@end
NS_ASSUME_NONNULL_END
