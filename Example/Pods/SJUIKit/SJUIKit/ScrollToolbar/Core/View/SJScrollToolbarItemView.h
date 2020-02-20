//
//  SJScrollToolbarItemView.h
//  SJScrollToolbar
//
//  Created by 畅三江 on 2019/12/23.
//

#import <UIKit/UIKit.h>
#import "SJScrollToolbarDefines.h"
@protocol SJScrollToolbarItemViewDelegate;

NS_ASSUME_NONNULL_BEGIN
@interface SJScrollToolbarItemView : UIView
@property (nonatomic, strong, nullable) id<SJScrollToolbarItem> item;
@property (nonatomic, strong, null_resettable) UIColor *textColor;
@property (nonatomic, strong, null_resettable) UIFont *maximumFont;
@property (nonatomic) CGFloat zoomScale;
@property (nonatomic, weak, nullable) id<SJScrollToolbarItemViewDelegate> delegate;
@end

@protocol SJScrollToolbarItemViewDelegate <NSObject>
- (void)itemViewDidFinishLoadImage:(SJScrollToolbarItemView *)view;
@end
NS_ASSUME_NONNULL_END
