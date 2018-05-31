//
//  SJVideoPlayerFilmEditingControlView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/3/9.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJVideoPlayerFilmEditingStatus.h"
#import "SJVideoPlayerFilmEditingCommonHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface SJVideoPlayerFilmEditingControlView : UIView

@property (nonatomic, weak, nullable) id <SJVideoPlayerFilmEditingControlViewDataSource> dataSource;
@property (nonatomic, weak, nullable) id <SJVideoPlayerFilmEditingControlViewDelegate> delegate;
@property (nonatomic, weak, nullable) id <SJVideoPlayerFilmEditingPromptResource> resource;
@property (nonatomic, weak, nullable) id <SJVideoPlayerFilmEditingResultUpload> uploader;


#pragma mark - operation
@property (nonatomic, readonly) SJVideoPlayerFilmEditingOperation currentOperation; // user selected operation.
@property (nonatomic) BOOL disableScreenshot;   // default is NO
@property (nonatomic) BOOL disableRecord;       // default is NO
@property (nonatomic) BOOL disableGIF;          // default is NO


#pragma mark -
@property (nonatomic, readonly) SJVideoPlayerFilmEditingStatus status;
- (void)pause;      // `filmEditingControlView:statusChanged:` will be called.
- (void)resume;     // `filmEditingControlView:statusChanged:` will be called.
- (void)cancel;     // `filmEditingControlView:statusChanged:` will be called.
- (void)finalize;   // `filmEditingControlView:statusChanged:` will be called.

@end
NS_ASSUME_NONNULL_END
