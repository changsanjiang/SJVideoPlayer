//
//  SJAVMediaPresentController.h
//  Pods
//
//  Created by 畅三江 on 2019/10/5.
//

#import <UIKit/UIKit.h>
#import "SJAVMediaPresentView.h"
@protocol SJAVMediaPresentControllerDelegate;

NS_ASSUME_NONNULL_BEGIN
@interface SJAVMediaPresentController : NSObject
@property (nonatomic, strong, readonly) UIView *view;
@property (nonatomic, strong, readonly, nullable) SJAVMediaPresentView *keyPresentView;
@property (nonatomic, weak, nullable) id<SJAVMediaPresentControllerDelegate> delegate;
@property (nonatomic, copy, null_resettable) AVLayerVideoGravity videoGravity;

- (void)insertPresentViewToBack:(SJAVMediaPresentView *)view;
- (void)removePresentView:(SJAVMediaPresentView *)view;
- (void)makeKeyPresentView:(SJAVMediaPresentView *)view;
- (void)removeAllPresentView;
@end

@protocol SJAVMediaPresentControllerDelegate <NSObject>
- (void)presentController:(SJAVMediaPresentController *)controller presentViewReadyForDisplayDidChange:(SJAVMediaPresentView *)presentView;
@end
NS_ASSUME_NONNULL_END
