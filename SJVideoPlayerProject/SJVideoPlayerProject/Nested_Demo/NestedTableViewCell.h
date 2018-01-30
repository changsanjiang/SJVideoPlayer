//
//  NestedTableViewCell.h
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/1/11.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PlayerCollectionViewCell;

@protocol NestedTableViewCellDelegate;



@interface NestedTableViewCell : UITableViewCell

+ (CGFloat)height;

@property (nonatomic, weak, readwrite, nullable) id<NestedTableViewCellDelegate> delegate;

@end



@protocol NestedTableViewCellDelegate <NSObject>

@optional

/**
 点击播放, 回调的代理方法

 @param tabCell `NestedTableViewCell`
 @param playerParentView `需要添加播放器的视图`
 @param indexPath `collection Cell的`indexPath`
 @param collectionView `tabCell`内部嵌套的`collectionview`
 */
- (void)clickedPlayWithNestedTabCell:(NestedTableViewCell *)tabCell
                    playerParentView:(UIView *)playerParentView
                           indexPath:(NSIndexPath *__nullable)indexPath
                      collectionView:(UICollectionView *)collectionView;
@end

NS_ASSUME_NONNULL_END
