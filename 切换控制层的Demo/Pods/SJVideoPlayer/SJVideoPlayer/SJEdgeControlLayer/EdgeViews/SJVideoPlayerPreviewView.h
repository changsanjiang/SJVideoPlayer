//
//  SJVideoPlayerPreviewView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/12/4.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#if __has_include(<SJBaseVideoPlayer/SJVideoPlayerPreviewInfo.h>)
#import <SJBaseVideoPlayer/SJVideoPlayerPreviewInfo.h>
#else
#import "SJVideoPlayerPreviewInfo.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@protocol SJVideoPlayerPreviewViewDelegate;

@interface SJVideoPlayerPreviewView : UIView

@property (nonatomic, weak, readwrite, nullable) id<SJVideoPlayerPreviewViewDelegate> delegate;

@property (nonatomic, strong, readwrite) NSArray<id<SJVideoPlayerPreviewInfo>> *previewImages;

@property (nonatomic) BOOL fullscreen;

@end

@protocol SJVideoPlayerPreviewViewDelegate <NSObject>
			
@optional
- (void)previewView:(SJVideoPlayerPreviewView *)view didSelectItem:(id<SJVideoPlayerPreviewInfo>)item;

@end

NS_ASSUME_NONNULL_END
