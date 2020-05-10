//
//  SJUICollectionViewDemoViewController1.h
//  SJVideoPlayer_Example
//
//  Created by BlueDancer on 2020/5/10.
//  Copyright © 2020 changsanjiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SJVideoPlayer/SJVideoPlayer.h>

NS_ASSUME_NONNULL_BEGIN

@interface SJUICollectionViewDemoViewController1 : UIViewController<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate>
@property (nonatomic, strong, readonly) UICollectionView *collectionView;
@property (nonatomic, strong, nullable) SJVideoPlayer *player;
@end

NS_ASSUME_NONNULL_END
