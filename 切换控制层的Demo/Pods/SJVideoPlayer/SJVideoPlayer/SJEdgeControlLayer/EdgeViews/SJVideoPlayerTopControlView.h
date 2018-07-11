//
//  SJVideoPlayerTopControlView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/11/29.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SJVideoPlayerTopViewTag) {
    SJVideoPlayerTopViewTag_Back,
    SJVideoPlayerTopViewTag_Preview,
    SJVideoPlayerTopViewTag_More,
};


@interface SJVideoPlayerTopControlModel : NSObject

@property (nonatomic) BOOL fullscreen;
@property (nonatomic) BOOL alwaysShowTitle;
@property (nonatomic) BOOL isPlayOnScrollView;
@property (nonatomic, copy, nullable) NSString *title;

@end

@protocol SJVideoPlayerTopControlViewDelegate;

@interface SJVideoPlayerTopControlView : UIView

@property (nonatomic, weak, readwrite, nullable) id<SJVideoPlayerTopControlViewDelegate> delegate;

@property (nonatomic, strong, readonly) SJVideoPlayerTopControlModel *model;

@property (nonatomic, strong, readonly) NSString *previewTitle;

- (void)needUpdateLayout;

@end

@protocol SJVideoPlayerTopControlViewDelegate <NSObject>

@required
- (BOOL)hasBeenGeneratedPreviewImages;

@optional
- (void)topControlView:(SJVideoPlayerTopControlView *)view clickedBtnTag:(SJVideoPlayerTopViewTag)tag;

@end

NS_ASSUME_NONNULL_END
