//
//  SJWatermarkView.h
//  Pods
//
//  Created by BlueDancer on 2020/6/13.
//

#import "SJWatermarkViewDefines.h"

typedef NS_ENUM(NSUInteger, SJWatermarkLayoutPosition) {
    SJWatermarkLayoutPositionTopLeft,
    SJWatermarkLayoutPositionTopRight,
    SJWatermarkLayoutPositionBottomLeft,
    SJWatermarkLayoutPositionBottomRight
};

NS_ASSUME_NONNULL_BEGIN

@interface SJWatermarkView : UIImageView<SJWatermarkView>

@property (nonatomic) SJWatermarkLayoutPosition layoutPosition; // default value is SJWatermarkLayoutPositionTopRight.
@property (nonatomic) UIEdgeInsets layoutInsets; // default value is (20, 20, 20, 20).
@property (nonatomic) CGFloat layoutHeight; // default value is 0. If `0`, the height of the watermark image will be used for layout.

- (void)layoutWatermarkInRect:(CGRect)rect videoPresentationSize:(CGSize)vSize videoGravity:(SJVideoGravity)videoGravity;

@end

NS_ASSUME_NONNULL_END
