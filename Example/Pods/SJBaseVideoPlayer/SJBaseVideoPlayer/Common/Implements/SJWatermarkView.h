//
//  SJWatermarkView.h
//  Pods
//
//  Created by BlueDancer on 2020/6/13.
//

#import "SJWatermarkViewDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface SJWatermarkView : UIImageView<SJWatermarkView>

@property (nonatomic) CGFloat margin; // default value is 20.0

- (void)layoutWatermarkInRect:(CGRect)rect videoPresentationSize:(CGSize)vSize videoGravity:(SJVideoGravity)videoGravity;

@end

NS_ASSUME_NONNULL_END
