//
//  SJSwitchVideoDefinitionControlLayer.h
//  Pods
//
//  Created by 畅三江 on 2019/7/12.
//

#import "SJEdgeControlLayerAdapters.h"
#import "SJControlLayerDefines.h"
#import "SJVideoPlayerURLAsset+SJExtendedDefinition.h"
@protocol SJSwitchVideoDefinitionControlLayerDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface SJSwitchVideoDefinitionControlLayer : SJEdgeControlLayerAdapters<SJControlLayer>

@property (nonatomic, copy, nullable) NSArray<SJVideoPlayerURLAsset *> *assets;

@property (nonatomic, weak, nullable) id<SJSwitchVideoDefinitionControlLayerDelegate> delegate;

@property (nonatomic, strong, null_resettable) UIColor *selectedTextColor;
@end

@protocol SJSwitchVideoDefinitionControlLayerDelegate <NSObject>

- (void)controlLayer:(SJSwitchVideoDefinitionControlLayer *)controlLayer didSelectAsset:(SJVideoPlayerURLAsset *)asset;

- (void)tappedBlankAreaOnTheControlLayer:(id<SJControlLayer>)controlLayer;

@end
NS_ASSUME_NONNULL_END
