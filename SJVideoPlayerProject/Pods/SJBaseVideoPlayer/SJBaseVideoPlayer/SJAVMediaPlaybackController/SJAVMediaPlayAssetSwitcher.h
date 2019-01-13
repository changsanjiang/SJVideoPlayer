//
//  SJAVMediaPlayAssetSwitcher.h
//  Pods
//
//  Created by 畅三江 on 2019/1/13.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "SJVideoPlayerRegistrar.h"
@protocol SJAVPlayerLayerPresenter;
@class SJAVMediaPlayAsset, SJAVMediaPlayAssetSwitcher;

NS_ASSUME_NONNULL_BEGIN
typedef void(^SJSwitchVideoDefinitionCompletionHandler)(SJAVMediaPlayAssetSwitcher *switcher, BOOL result, SJAVMediaPlayAsset *_Nullable newAsset);

@interface SJAVMediaPlayAssetSwitcher : NSObject
- (instancetype)initWithURL:(NSURL *)URL
                  presenter:(id<SJAVPlayerLayerPresenter>)presenter
                currentTime:(CMTime(^)(void))currentTime
          completionHandler:(SJSwitchVideoDefinitionCompletionHandler)completionHandler;

@property (nonatomic, strong, readonly) NSURL *URL;
@property (nonatomic, strong, readonly) id<SJAVPlayerLayerPresenter> presenter;
@end
NS_ASSUME_NONNULL_END
