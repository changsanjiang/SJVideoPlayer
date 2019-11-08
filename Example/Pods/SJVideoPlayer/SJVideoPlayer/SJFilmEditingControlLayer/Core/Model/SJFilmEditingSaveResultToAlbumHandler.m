//
//  SJFilmEditingSaveResultToAlbumHandler.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2019/1/20.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import "SJFilmEditingSaveResultToAlbumHandler.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "SJVideoPlayerFilmEditingCommonHeader.h"
#import "SJFilmEditingSettings.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJFilmEditingSaveResultFailed : NSObject<SJFilmEditingSaveResultFailed>
- (instancetype)initWithReason:(SJFilmEditingSaveResultToAlbumFailedReason)reason;
@end

@implementation SJFilmEditingSaveResultFailed
@synthesize reason = _reason;

- (instancetype)initWithReason:(SJFilmEditingSaveResultToAlbumFailedReason)reason {
    self = [super init];
    if ( !self ) return nil;
    _reason = reason;
    return self;
}

- (NSString *)toString {
    switch ( _reason ) {
        case SJFilmEditingSaveResultToAlbumFailedReasonAuthDenied:
            return SJFilmEditingSettings.commonSettings.albumAuthDeniedText;
    }
}
@end


@interface SJFilmEditingSaveResultToAlbumHandler ()
@property (nonatomic, copy, nullable) void(^completionHandler)(BOOL r, id<SJFilmEditingSaveResultFailed> failed);
@end

@implementation SJFilmEditingSaveResultToAlbumHandler
- (void)saveResult:(id<SJVideoPlayerFilmEditingResult>)result completionHandler:(void (^)(BOOL, id<SJFilmEditingSaveResultFailed> _Nonnull))completionHandler {
    _completionHandler = completionHandler;
    
    switch ( result.operation ) {
        case SJVideoPlayerFilmEditingOperation_Unknown:
            break;
        case SJVideoPlayerFilmEditingOperation_Screenshot: {
            [self _saveScreenshot:result];
        }
            break;
        case SJVideoPlayerFilmEditingOperation_Export: {
            [self _saveVideo:result];
        }
            break;
        case SJVideoPlayerFilmEditingOperation_GIF: {
            [self _saveGIF:result];
        }
            break;
    }
}

- (void)_saveScreenshot:(id<SJVideoPlayerFilmEditingResult>)result {
    UIImageWriteToSavedPhotosAlbum(result.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

- (void)_saveGIF:(id<SJVideoPlayerFilmEditingResult>)result {
    __weak typeof(self) _self = self;
    if ( @available(iOS 9.0, *) ) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            switch ( status ) {
                case PHAuthorizationStatusNotDetermined:
                case PHAuthorizationStatusRestricted:
                case PHAuthorizationStatusDenied: {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ( self.completionHandler ) self.completionHandler(NO, [[SJFilmEditingSaveResultFailed alloc] initWithReason:SJFilmEditingSaveResultToAlbumFailedReasonAuthDenied]);
                    });
                }
                    break;
                case PHAuthorizationStatusAuthorized: {
                    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                        [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:result.fileURL];
                    } completionHandler:^(BOOL success, NSError *error) {
                        __strong typeof(_self) self = _self;
                        if ( !self ) return ;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if ( self.completionHandler ) self.completionHandler(!error, error?[[SJFilmEditingSaveResultFailed alloc] initWithReason:SJFilmEditingSaveResultToAlbumFailedReasonAuthDenied]:nil);
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
                if ( self.completionHandler ) self.completionHandler(!error, error?[[SJFilmEditingSaveResultFailed alloc] initWithReason:SJFilmEditingSaveResultToAlbumFailedReasonAuthDenied]:nil);
            });
        }];
#pragma clang diagnostic pop
    }
}

- (void)_saveVideo:(id<SJVideoPlayerFilmEditingResult>)result {
    UISaveVideoAtPathToSavedPhotosAlbum(result.fileURL.path, self, @selector(video:didFinishSavingWithError:contextInfo:), NULL);
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if ( _completionHandler ) _completionHandler(!error, error?[[SJFilmEditingSaveResultFailed alloc] initWithReason:SJFilmEditingSaveResultToAlbumFailedReasonAuthDenied]:nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if ( _completionHandler ) _completionHandler(!error, error?[[SJFilmEditingSaveResultFailed alloc] initWithReason:SJFilmEditingSaveResultToAlbumFailedReasonAuthDenied]:nil);
}

@end
NS_ASSUME_NONNULL_END
