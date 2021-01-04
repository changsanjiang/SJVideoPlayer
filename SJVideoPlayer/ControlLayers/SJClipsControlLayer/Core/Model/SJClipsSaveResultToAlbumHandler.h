//
//  SJClipsSaveResultToAlbumHandler.h
//  SJVideoPlayer
//
//  Created by 畅三江 on 2019/1/20.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol SJVideoPlayerClipsResult;

NS_ASSUME_NONNULL_BEGIN
typedef enum : NSUInteger {
    SJClipsSaveResultToAlbumFailedReasonAuthDenied,
} SJClipsSaveResultToAlbumFailedReason;

@protocol SJClipsSaveResultFailed <NSObject>
@property (nonatomic, readonly) SJClipsSaveResultToAlbumFailedReason reason;
- (NSString *)toString;
@end

@protocol SJClipsSaveResultToAlbumHandler <NSObject>
- (void)saveResult:(id<SJVideoPlayerClipsResult>)result completionHandler:(void(^)(BOOL r, id<SJClipsSaveResultFailed> failed))completionHandler;
@end

@interface SJClipsSaveResultToAlbumHandler : NSObject<SJClipsSaveResultToAlbumHandler>

@end
NS_ASSUME_NONNULL_END
