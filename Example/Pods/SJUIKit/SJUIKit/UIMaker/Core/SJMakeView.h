//
//  SJMakeView.h
//  Pods
//
//  Created by BlueDancer on 2019/2/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
#pragma mark - UIView
@interface SJMakeView : NSObject
@property (nonatomic, copy, readonly) SJMakeView *(^frame)(CGRect frame);
@property (nonatomic, copy, readonly) SJMakeView *(^backgroundColor)(UIColor *color); // default white.
@property (nonatomic, copy, readonly) SJMakeView *(^contentMode)(UIViewContentMode contentMode);
@property (nonatomic, copy, readonly) SJMakeView *(^clipsToBounds)(BOOL clipsToBounds);
- (__kindof UIView *)install;
@end

#pragma mark - UIImageView
@interface SJMakeImageView : SJMakeView
@property (nonatomic, copy, readonly) SJMakeImageView *(^image)(UIImage *image);
@end

#pragma mark - UIScrollView
@interface SJMakeScrollView : SJMakeView
@property (nonatomic, copy, readonly) SJMakeScrollView *(^contentOffset)(CGPoint contentOffset);
@property (nonatomic, copy, readonly) SJMakeScrollView *(^contentSize)(CGSize contentSize);
@property (nonatomic, copy, readonly) SJMakeScrollView *(^contentInset)(UIEdgeInsets contentInset);
@property (nonatomic, copy, readonly) SJMakeScrollView *(^delegate)(id<UIScrollViewDelegate> delegate);
@property (nonatomic, copy, readonly) SJMakeScrollView *(^pagingEnabled)(BOOL pagingEnabled);
@property (nonatomic, copy, readonly) SJMakeScrollView *(^scrollEnabled)(BOOL scrollEnabled);
@property (nonatomic, copy, readonly) SJMakeScrollView *(^showsHorizontalScrollIndicator)(BOOL showsHorizontalScrollIndicator);
@property (nonatomic, copy, readonly) SJMakeScrollView *(^showsVerticalScrollIndicator)(BOOL showsVerticalScrollIndicator);
@property (nonatomic, copy, readonly) SJMakeScrollView *(^scrollIndicatorInsets)(UIEdgeInsets scrollIndicatorInsets);
@property (nonatomic, copy, readonly) SJMakeScrollView *(^indicatorStyle)(UIScrollViewIndicatorStyle   indicatorStyle);
@property (nonatomic, copy, readonly) SJMakeScrollView *(^keyboardDismissMode)(UIScrollViewKeyboardDismissMode keyboardDismissMode);
@end

#pragma mark - UITableView
@interface SJMakeTableView : SJMakeScrollView
@property (nonatomic, copy, readonly) SJMakeTableView *(^style)(UITableViewStyle style);
@property (nonatomic, copy, readonly) SJMakeTableView *(^delegate)(id<UITableViewDelegate> delegate);
@property (nonatomic, copy, readonly) SJMakeTableView *(^dataSource)(id<UITableViewDataSource> dataSource);
@property (nonatomic, copy, readonly) SJMakeTableView *(^separatorStyle)(UITableViewCellSeparatorStyle style);
@property (nonatomic, copy, readonly) SJMakeTableView *(^separatorColor)(UIColor *color);
@property (nonatomic, copy, readonly) SJMakeTableView *(^rowHeight)(CGFloat rowHeight);
@end
NS_ASSUME_NONNULL_END
