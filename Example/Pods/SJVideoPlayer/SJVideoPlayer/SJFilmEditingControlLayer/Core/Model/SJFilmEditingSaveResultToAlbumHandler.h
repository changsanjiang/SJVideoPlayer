//
//  SJFilmEditingSaveResultToAlbumHandler.h
//  SJVideoPlayer
//
//  Created by 畅三江 on 2019/1/20.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol SJVideoPlayerFilmEditingResult;

NS_ASSUME_NONNULL_BEGIN
typedef enum : NSUInteger {
    SJFilmEditingSaveResultToAlbumFailedReasonAuthDenied,
} SJFilmEditingSaveResultToAlbumFailedReason;

@protocol SJFilmEditingSaveResultFailed <NSObject>
@property (nonatomic, readonly) SJFilmEditingSaveResultToAlbumFailedReason reason;
- (NSString *)toString;
@end

@protocol SJFilmEditingSaveResultToAlbumHandler <NSObject>
- (void)saveResult:(id<SJVideoPlayerFilmEditingResult>)result completionHandler:(void(^)(BOOL r, id<SJFilmEditingSaveResultFailed> failed))completionHandler;
@end

@interface SJFilmEditingSaveResultToAlbumHandler : NSObject<SJFilmEditingSaveResultToAlbumHandler>

@end
NS_ASSUME_NONNULL_END
