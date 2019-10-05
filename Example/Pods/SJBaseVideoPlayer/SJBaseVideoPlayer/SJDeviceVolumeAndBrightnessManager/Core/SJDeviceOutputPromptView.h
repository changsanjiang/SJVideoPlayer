//
//  SJDeviceOutputPromptView.h
//  Pods
//
//  Created by 畅三江 on 2019/8/6.
//

#import <UIKit/UIKit.h>
@protocol SJDeviceOutputPromptViewDataSource;

NS_ASSUME_NONNULL_BEGIN
@interface SJDeviceOutputPromptView : UIView
@property (nonatomic, weak, nullable) id<SJDeviceOutputPromptViewDataSource> dataSource;

- (void)refreshData;
@end

@protocol SJDeviceOutputPromptViewDataSource <NSObject>
@property (nonatomic, strong, readonly, nullable) UIImage *image;
@property (nonatomic, readonly) float progress;
@property (nonatomic, strong, readonly, nullable) UIColor *traceColor;
@property (nonatomic, strong, readonly, nullable) UIColor *trackColor;
@end

@interface SJDeviceOutputPromptViewModel : NSObject<SJDeviceOutputPromptViewDataSource>
@property (nonatomic, strong, nullable) UIImage *image;
@property (nonatomic) float progress;
@property (nonatomic, strong, nullable) UIColor *traceColor;
@property (nonatomic, strong, nullable) UIColor *trackColor;
@end
NS_ASSUME_NONNULL_END
