//
//  SJTopView.h
//  SJPageViewController_Example
//
//  Created by BlueDancer on 2020/5/6.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SJTopViewDelegate;

NS_ASSUME_NONNULL_BEGIN
@interface SJTopView : UIView
@property (nonatomic, strong, readonly) UIView *contentView;
@property (nonatomic, weak, nullable) id<SJTopViewDelegate> delegate;
@end

@protocol SJTopViewDelegate <NSObject>
- (void)playButtonWasTapped:(SJTopView *)bar;
@end
NS_ASSUME_NONNULL_END
