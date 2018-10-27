//
//  SJEdgeLightweightControlLayer.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/3/21.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJControlLayerCarrier.h"
#import "SJLightweightTopItem.h"

NS_ASSUME_NONNULL_BEGIN
@protocol SJEdgeLightweightControlLayerDelegate;

/**
 轻量级的控制层
 */
@interface SJEdgeLightweightControlLayer : NSObject<SJControlLayer>
@property (nonatomic, weak, nullable) id <SJEdgeLightweightControlLayerDelegate> delegate;

@property (nonatomic, strong, nullable) NSArray<SJLightweightTopItem *> *topItems;

@property (nonatomic) BOOL disablePromptWhenNetworkStatusChanges;

@property (nonatomic) BOOL enableFilmEditing;

@property (nonatomic) BOOL hideBackButtonWhenOrientationIsPortrait;

@end


@protocol SJEdgeLightweightControlLayerDelegate <NSObject>

@optional
/// 点击返回按钮
- (void)clickedBackBtnOnLightweightControlLayer:(SJEdgeLightweightControlLayer *)controlLayer;
/// 点击顶部控制层上的item
- (void)lightwieghtControlLayer:(SJEdgeLightweightControlLayer *)controlLayer clickedTopControlItem:(SJLightweightTopItem *)item;
/// 点击右侧控制层按钮
- (void)clickedFilmEditingBtnOnLightweightControlLayer:(SJEdgeLightweightControlLayer *)controlLayer;
@end

NS_ASSUME_NONNULL_END
