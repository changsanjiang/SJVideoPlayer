//
//  SJVideoPlayPreviewColCell.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/9/25.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJVideoPreviewModel;

@protocol SJVideoPlayPreviewColCellDelegate;


@interface SJVideoPlayPreviewColCell : UICollectionViewCell

@property (nonatomic, strong, readwrite) SJVideoPreviewModel *model;
@property (nonatomic, weak) id <SJVideoPlayPreviewColCellDelegate> delegate;

@end


@protocol SJVideoPlayPreviewColCellDelegate <NSObject>

@optional
- (void)clickedItemOnCell:(SJVideoPlayPreviewColCell *)cell;

@end

