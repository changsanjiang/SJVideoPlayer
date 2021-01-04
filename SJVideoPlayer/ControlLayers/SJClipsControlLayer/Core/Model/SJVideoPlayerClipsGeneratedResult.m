//
//  SJVideoPlayerClipsGeneratedResult.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2019/1/20.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import "SJVideoPlayerClipsGeneratedResult.h"

@implementation SJVideoPlayerClipsGeneratedResult

- (NSData * _Nullable)data {
    if ( self.fileURL )
        return [NSData dataWithContentsOfURL:self.fileURL];
    else if ( self.image )
        return UIImagePNGRepresentation(self.image);
    return nil;
}

- (void)setExportState:(SJClipsExportState)exportState {
    if ( exportState == _exportState )
     return;
    _exportState = exportState;
    if ( _exportStateDidChangeExeBlock ) _exportStateDidChangeExeBlock(self);
}

- (void)setExportProgress:(float)exportProgress {
    _exportProgress = exportProgress;
    if ( _exportProgressDidChangeExeBlock ) _exportProgressDidChangeExeBlock(self);
}

- (void)setUploadState:(SJClipsResultUploadState)uploadState {
    if ( uploadState == _uploadState )
        return;
    _uploadState = uploadState;
    if ( _uploadStateDidChangeExeBlock ) _uploadStateDidChangeExeBlock(self);
}

- (void)setUploadProgress:(float)uploadProgress {
    _uploadProgress = uploadProgress;
    if ( _uploadProgressDidChangeExeBlock ) _uploadProgressDidChangeExeBlock(self);
}

@end
