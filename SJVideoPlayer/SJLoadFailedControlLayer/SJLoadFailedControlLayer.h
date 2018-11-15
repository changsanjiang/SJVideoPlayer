//
//  SJLoadFailedControlLayer.h
//  SJVideoPlayer
//
//  Created by 畅三江 on 2018/10/27.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import "SJEdgeControlLayerAdapters.h"
#import "SJControlLayerCarrier.h"

NS_ASSUME_NONNULL_BEGIN
extern SJEdgeControlButtonItemTag const SJLoadFailedControlLayerTopItem_Back;             // 返回按钮

@interface SJLoadFailedControlLayer : SJEdgeControlLayerAdapters<SJControlLayer> 
@property (nonatomic, copy, nullable) void(^clickedBackItemExeBlock)(SJLoadFailedControlLayer *control);
@property (nonatomic, copy, nullable) void(^clickedFaliedButtonExeBlock)(SJLoadFailedControlLayer *control);
@property (nonatomic, copy, nullable) void(^prepareToPlayNewAssetExeBlock)(SJLoadFailedControlLayer *control);
@end
NS_ASSUME_NONNULL_END
