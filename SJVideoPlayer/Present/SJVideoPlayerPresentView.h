//
//  SJVideoPlayerPresentView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/8/18.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, SJVideoPlayerPresentOrientation) {
    SJVideoPlayerPresentOrientationPortrait = 0,
    SJVideoPlayerPresentOrientationLandscapeLeft,
    SJVideoPlayerPresentOrientationLandscapeRight,
};


@class AVPlayer, AVAsset, SJVideoPlayerAssetCarrier;

@interface SJVideoPlayerPresentView : UIView

@property (nonatomic, weak, readwrite) SJVideoPlayerAssetCarrier *assetCarrier;

- (void)setPlaceholderImage:(UIImage *)placeholderImage;

@property (nonatomic, copy, readwrite) void(^back)(void);

- (void)sjReset;

- (UIImage *)screenshot;

@property (nonatomic, assign, readonly) BOOL isLandscapeVideo;

@end


#pragma mark -

@interface SJVideoPlayerPresentView (PresentViewRotation)

/*!
 *  default is Portrait.
 */
@property (nonatomic, assign, readonly) SJVideoPlayerPresentOrientation orientation;

/*!
 *  default is NO.
 */
@property (nonatomic, assign, readwrite, getter=isEnabledRotation) BOOL enabledRotation;

@end


#pragma mark -

#import "SJVideoPlayerControl.h"

@interface SJVideoPlayerPresentView (ControlDelegateMethods)<SJVideoPlayerControlDelegate>

@end




#pragma mark -

#import "SJVideoPlayerAssetCarrier.h"

@interface SJVideoPlayerAssetCarrier (PresentViewExtention)

@property (nonatomic, weak) UIView *presentViewSuperView;

@end
