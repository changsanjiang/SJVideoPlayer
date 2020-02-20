//
//  SJPageCollectionView.h
//  Pods
//
//  Created by 畅三江 on 2020/2/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SJPageCollectionView : UICollectionView

@end

@protocol SJPageCollectionViewDelegate <UICollectionViewDelegate>
- (BOOL)collectionView:(UICollectionView *)collectionView gestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer;
@end
NS_ASSUME_NONNULL_END
