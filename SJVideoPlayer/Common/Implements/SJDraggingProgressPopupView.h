//
//  SJDraggingProgressPopupView.h
//  Pods
//
//  Created by 畅三江 on 2019/11/27.
//

#import <UIKit/UIKit.h>
#import "SJDraggingProgressPopupViewDefines.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJDraggingProgressPopupView : UIView<SJDraggingProgressPopupView>
///
/// 当需要显示预览时, 可以返回NO, 管理类将会设置previewImage
///
@property (nonatomic, readonly, getter=isPreviewImageHidden) BOOL previewImageHidden;
@property (nonatomic, strong, nullable) UIImage *previewImage;
@property (nonatomic) SJDraggingProgressPopupViewStyle style;
@property (nonatomic) NSTimeInterval dragTime;
@property (nonatomic) NSTimeInterval currentTime;
@property (nonatomic) NSTimeInterval duration;
@end
NS_ASSUME_NONNULL_END
