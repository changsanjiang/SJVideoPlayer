//
//  SJLightweightRightControlView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/4/12.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, SJVideoPlayerRightViewTag) {
    SJVideoPlayerRightViewTag_FilmEditing,
};

@protocol SJLightweightRightControlViewDelegate;

@interface SJLightweightRightControlView : UIView

@property (nonatomic, weak, readwrite, nullable) id<SJLightweightRightControlViewDelegate> delegate;

@property (nonatomic, strong, nullable) UIImage *filmEditingBtnImage;

@end

@protocol SJLightweightRightControlViewDelegate <NSObject>

@optional
- (void)rightControlView:(SJLightweightRightControlView *)view clickedBtnTag:(SJVideoPlayerRightViewTag)tag;

@end
