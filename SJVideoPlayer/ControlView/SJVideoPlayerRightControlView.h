//
//  SJVideoPlayerRightControlView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/3/8.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, SJVideoPlayerRightViewTag) {
    SJVideoPlayerRightViewTag_FilmEditing,
};

@protocol SJVideoPlayerRightControlViewDelegate;

@interface SJVideoPlayerRightControlView : UIView

@property (nonatomic, weak, readwrite, nullable) id<SJVideoPlayerRightControlViewDelegate> delegate;

@property (nonatomic, strong, nullable) UIImage *filmEditingBtnImage;

@end

@protocol SJVideoPlayerRightControlViewDelegate <NSObject>
			
@optional
- (void)rightControlView:(SJVideoPlayerRightControlView *)view clickedBtnTag:(SJVideoPlayerRightViewTag)tag;

@end
NS_ASSUME_NONNULL_END
