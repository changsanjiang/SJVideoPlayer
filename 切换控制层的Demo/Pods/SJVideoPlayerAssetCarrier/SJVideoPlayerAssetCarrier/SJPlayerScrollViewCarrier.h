//
//  SJPlayerScrollViewCarrier.h
//  SJVideoPlayerAssetCarrier
//
//  Created by BlueDancer on 2018/5/21.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol SJPlayerScrollViewCarrierDelegate;

@interface SJPlayerScrollViewCarrier : NSObject

/// player super view -> table or collection cell -> table or collection view
- (instancetype)initWithPlayerSuperViewTag:(NSInteger)playerSuperViewTag
                                 indexPath:(NSIndexPath *)indexPath
                                scrollView:(__unsafe_unretained UIScrollView *)tableViewOrCollectionView;

/// player super view -> collection cell -> collection view -> table cell -> table view
- (instancetype)initWithPlayerSuperViewTag:(NSInteger)playerSuperViewTag
                                 indexPath:(NSIndexPath *__nullable)indexPath
                                scrollView:(__unsafe_unretained UIScrollView *__nullable)tableViewOrCollectionView
                             scrollViewTag:(NSInteger)scrollViewTag
                       scrollViewIndexPath:(NSIndexPath *__nullable)scrollViewIndexPath
                            rootScrollView:(__unsafe_unretained UIScrollView *__nullable)rootScrollView;

/// player super view -> table header view -> table view
- (instancetype)initWithPlayerSuperViewOfTableHeader:(__unsafe_unretained UIView *)playerSuperView
                                           tableView:(__unsafe_unretained UITableView *)tableView;

/// player super view -> collection cell -> table header view -> table view
- (instancetype)initWithPlayerSuperViewTag:(NSInteger)playerSuperViewTag
                                 indexPath:(NSIndexPath *)indexPath
               collectionViewOfTableHeader:(__unsafe_unretained UICollectionView *)collectionView
                             rootTableView:(__unsafe_unretained UITableView *)rootTableView;

@property (nonatomic, weak) id<SJPlayerScrollViewCarrierDelegate> delegate;
@property (nonatomic, readonly) BOOL touchedScrollView;



#pragma mark -
@property (nonatomic, unsafe_unretained, readonly, nullable) UIScrollView *rootScrollView;
@property (nonatomic, unsafe_unretained, readonly, nullable) UIView *tableHeaderSubView;
@property (nonatomic, unsafe_unretained, readonly, nullable) UIScrollView *scrollView;
@property (nonatomic, strong, readonly, nullable) NSIndexPath *scrollViewIndexPath;
@property (nonatomic, readonly) NSInteger scrollViewTag;
@property (nonatomic, strong, readonly) NSIndexPath *indexPath;
@property (nonatomic, readonly) NSInteger superviewTag;
@end

@protocol SJPlayerScrollViewCarrierDelegate <NSObject>
@optional
/// touched`scrollView`时调用
- (void)scrollViewCarrier:(SJPlayerScrollViewCarrier *)carrier touchedScrollView:(BOOL)touched;
/// 播放器视图即将出现的时候调用
- (void)playerWillAppearForScrollViewCarrier:(SJPlayerScrollViewCarrier *)carrier superview:(UIView *)superview;
/// 播放器视图即将消失的时候调用
- (void)playerWillDisappearForScrollViewCarrier:(SJPlayerScrollViewCarrier *)carrier;
@end
NS_ASSUME_NONNULL_END
