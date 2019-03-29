//
//  SJAVMediaPlayAssetLoader.h
//  Pods
//
//  Created by 畅三江 on 2019/1/13.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@class SJAVMediaPlayAsset;
@protocol SJMediaModelProtocol;

NS_ASSUME_NONNULL_BEGIN
typedef void(^SJAVMediaLoadStatusDidChangeHandler)(AVPlayerItemStatus status);

extern SJAVMediaPlayAsset *
sj_assetForMedia(id<SJMediaModelProtocol> media);

extern void
sj_removeAssetForMedia(id<SJMediaModelProtocol> _Nullable media);

@interface SJAVMediaAssetLoader : NSObject
- (instancetype)initWithAsset:(SJAVMediaPlayAsset *)asset
          loadStatusDidChange:(SJAVMediaLoadStatusDidChangeHandler)handler;
@property (nonatomic, strong, readonly) SJAVMediaPlayAsset *asset;
@end
NS_ASSUME_NONNULL_END

