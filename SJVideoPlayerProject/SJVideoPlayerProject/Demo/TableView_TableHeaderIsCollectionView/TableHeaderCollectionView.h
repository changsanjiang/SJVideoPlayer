//
//  TableHeaderCollectionView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/2/28.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableHeaderCollectionView : UIView

+ (CGFloat)height;

@property (nonatomic, copy) void(^clickedPlayBtnExeBlock)(TableHeaderCollectionView *view, UICollectionView *collectionView, NSIndexPath *indexPath, UIView *videoPlayerSuperView);

@end
