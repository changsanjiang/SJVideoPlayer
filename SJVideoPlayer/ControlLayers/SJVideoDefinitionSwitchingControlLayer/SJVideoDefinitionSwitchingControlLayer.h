//
//  SJVideoDefinitionSwitchingControlLayer.h
//  Pods
//
//  Created by 畅三江 on 2019/7/12.
//

#import "SJEdgeControlLayerAdapters.h"
#import "SJControlLayerDefines.h"
#import "SJVideoPlayerURLAsset+SJExtendedDefinition.h"

#pragma mark - 切换清晰度时的控制层

@protocol SJVideoDefinitionSwitchingControlLayerDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface SJVideoDefinitionSwitchingControlLayer : SJEdgeControlLayerAdapters<SJControlLayer>

@property (nonatomic, copy, nullable) NSArray<SJVideoPlayerURLAsset *> *assets;

@property (nonatomic, weak, nullable) id<SJVideoDefinitionSwitchingControlLayerDelegate> delegate;

@property (nonatomic, strong, null_resettable) UIColor *selectedTextColor;
@end

@protocol SJVideoDefinitionSwitchingControlLayerDelegate <NSObject>

- (void)controlLayer:(SJVideoDefinitionSwitchingControlLayer *)controlLayer didSelectAsset:(SJVideoPlayerURLAsset *)asset;

- (void)tappedBlankAreaOnTheControlLayer:(id<SJControlLayer>)controlLayer;

@end
NS_ASSUME_NONNULL_END
