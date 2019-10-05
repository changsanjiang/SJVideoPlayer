//
//  SJMoreSettingControlLayer.h
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2019/7/19.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import "SJEdgeControlLayerAdapters.h"
#import "SJControlLayerDefines.h"
@protocol SJMoreSettingControlLayerDelegate;

NS_ASSUME_NONNULL_BEGIN
extern SJEdgeControlButtonItemTag const SJMoreSettingControlLayerItem_Volume;
extern SJEdgeControlButtonItemTag const SJMoreSettingControlLayerItem_Brightness;
extern SJEdgeControlButtonItemTag const SJMoreSettingControlLayerItem_Rate;

@interface SJMoreSettingControlLayer : SJEdgeControlLayerAdapters<SJControlLayer>
@property (nonatomic, weak, nullable) id<SJMoreSettingControlLayerDelegate> delegate;
@end

@protocol SJMoreSettingControlLayerDelegate <NSObject>
- (void)tappedBlankAreaOnTheControlLayer:(id<SJControlLayer>)controlLayer;
@end
NS_ASSUME_NONNULL_END
