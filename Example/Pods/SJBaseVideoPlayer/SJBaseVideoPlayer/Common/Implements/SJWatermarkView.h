//
//  SJWatermarkView.h
//  Pods
//
//  Created by BlueDancer on 2020/6/13.
//

#import "SJWatermarkViewDefines.h"

NS_ASSUME_NONNULL_BEGIN

//水印位置 TopLeft=左上 TopRight=右上 BottomLeft=左下 BottomRight=右下
static NSString* const SJPosTopLeft                                 = @"TopLeft";
static NSString* const SJPosTopRight                                = @"TopRight";
static NSString* const SJPosBottomLeft                              = @"BottomLeft";
static NSString* const SJPosBottomRight                             = @"BottomRight";


@interface SJWatermarkView : UIImageView<SJWatermarkView>

@property(nonatomic,assign) CGPoint     margin_normal;              //!< 正常时距离边缘位置
@property(nonatomic,assign) CGPoint     margin_fullscreen;          //!< 全屏时距离边缘位置
@property(nonatomic,assign) CGFloat     height_normal;              //!< 正常时高度
@property(nonatomic,assign) CGFloat     height_fullscreen;          //!< 全屏时高度
@property(nonatomic,strong) NSString*   referPos;                   //!< 水印位置

- (void)layoutWatermarkInRect:(CGRect)rect videoPresentationSize:(CGSize)vSize videoGravity:(SJVideoGravity)videoGravity;

@end

NS_ASSUME_NONNULL_END
