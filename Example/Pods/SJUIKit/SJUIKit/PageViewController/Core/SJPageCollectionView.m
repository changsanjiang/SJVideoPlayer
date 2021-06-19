//
//  SJPageCollectionView.m
//  Pods
//
//  Created by BlueDancer on 2020/2/5.
//

#import "SJPageCollectionView.h"

@implementation SJPageCollectionView
- (BOOL)gestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ( [self.delegate respondsToSelector:@selector(collectionView:gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:)] ) {
        return [(id)self.delegate collectionView:self gestureRecognizer:gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:otherGestureRecognizer];
    }
    return NO;
}
@end
