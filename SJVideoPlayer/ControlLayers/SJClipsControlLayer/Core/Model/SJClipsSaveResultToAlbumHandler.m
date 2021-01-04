//
//  SJClipsSaveResultToAlbumHandler.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2019/1/20.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import "SJClipsSaveResultToAlbumHandler.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "SJVideoPlayerConfigurations.h"
#import "SJVideoPlayerClipsDefines.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJClipsSaveResultFailed : NSObject<SJClipsSaveResultFailed>
- (instancetype)initWithReason:(SJClipsSaveResultToAlbumFailedReason)reason;
@end

@implementation SJClipsSaveResultFailed
@synthesize reason = _reason;

- (instancetype)initWithReason:(SJClipsSaveResultToAlbumFailedReason)reason {
    self = [super init];
    if ( !self ) return nil;
    _reason = reason;
    return self;
}

- (NSString *)toString {
    switch ( _reason ) {
        case SJClipsSaveResultToAlbumFailedReasonAuthDenied:
            return SJVideoPlayerConfigurations.shared.localizedStrings.albumAuthDeniedPrompt;
    }
}
@end


@interface SJClipsSaveResultToAlbumHandler ()
@property (nonatomic, copy, nullable) void(^completionHandler)(BOOL r, id<SJClipsSaveResultFailed> failed);
@end

@implementation SJClipsSaveResultToAlbumHandler
- (void)saveResult:(id<SJVideoPlayerClipsResult>)result completionHandler:(void (^)(BOOL, id<SJClipsSaveResultFailed> _Nonnull))completionHandler {
    _completionHandler = completionHandler;
    
    switch ( result.operation ) {
        case SJVideoPlayerClipsOperation_Unknown:
            break;
        case SJVideoPlayerClipsOperation_Screenshot: {
            [self _saveScreenshot:result];
        }
            break;
        case SJVideoPlayerClipsOperation_Export: {
            [self _saveVideo:result];
        }
            break;
        case SJVideoPlayerClipsOperation_GIF: {
            [self _saveGIF:result];
        }
            break;
    }
}

- (void)_saveScreenshot:(id<SJVideoPlayerClipsResult>)result {
    UIImageWriteToSavedPhotosAlbum(result.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

- (void)_saveGIF:(id<SJVideoPlayerClipsResult>)result {
    __weak typeof(self) _self = self;
    if ( @available(iOS 9.0, *) ) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            switch ( status ) {
                case PHAuthorizationStatusNotDetermined:
                case PHAuthorizationStatusRestricted:
                case PHAuthorizationStatusDenied: {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ( self.completionHandler ) self.completionHandler(NO, [[SJClipsSaveResultFailed alloc] initWithReason:SJClipsSaveResultToAlbumFailedReasonAuthDenied]);
                    });
                }
                    break;
                case PHAuthorizationStatusLimited:
                case PHAuthorizationStatusAuthorized: {
                    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                        [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:result.fileURL];
                    } completionHandler:^(BOOL success, NSError *error) {
                        __strong typeof(_self) self = _self;
                        if ( !self ) return ;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if ( self.completionHandler ) self.completionHandler(!error, error?[[SJClipsSaveResultFailed alloc] initWithReason:SJClipsSaveResultToAlbumFailedReasonAuthDenied]:nil);
                        });
                    }];
                }
                    break;
            }
        }];
    }
    else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        NSDictionary *metadata = @{@"UTI":(__bridge NSString *)kUTTypeGIF};
        [library writeImageDataToSavedPhotosAlbum:result.data metadata:metadata completionBlock:^(NSURL *assetURL, NSError *error) {
            __strong typeof(_self) self = _self;
            if ( !self ) return ;
            dispatch_async(dispatch_get_main_queue(), ^{
                if ( self.completionHandler ) self.completionHandler(!error, error?[[SJClipsSaveResultFailed alloc] initWithReason:SJClipsSaveResultToAlbumFailedReasonAuthDenied]:nil);
            });
        }];
#pragma clang diagnostic pop
    }
}

- (void)_saveVideo:(id<SJVideoPlayerClipsResult>)result {
    UISaveVideoAtPathToSavedPhotosAlbum(result.fileURL.path, self, @selector(video:didFinishSavingWithError:contextInfo:), NULL);
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if ( _completionHandler ) _completionHandler(!error, error?[[SJClipsSaveResultFailed alloc] initWithReason:SJClipsSaveResultToAlbumFailedReasonAuthDenied]:nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if ( _completionHandler ) _completionHandler(!error, error?[[SJClipsSaveResultFailed alloc] initWithReason:SJClipsSaveResultToAlbumFailedReasonAuthDenied]:nil);
}

@end
NS_ASSUME_NONNULL_END
