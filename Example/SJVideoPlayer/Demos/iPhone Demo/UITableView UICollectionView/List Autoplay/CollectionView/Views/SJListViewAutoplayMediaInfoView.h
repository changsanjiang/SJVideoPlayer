//
//  SJListViewAutoplayMediaInfoView.h
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2019/8/16.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SJListViewAutoplayMediaInfoViewDataSource;

NS_ASSUME_NONNULL_BEGIN
@interface SJListViewAutoplayMediaInfoView : UIView
@property (nonatomic, weak, nullable) id<SJListViewAutoplayMediaInfoViewDataSource> dataSource;

- (void)reloadData;
@end

@protocol SJListViewAutoplayMediaInfoViewDataSource <NSObject>
@property (nonatomic, copy, readonly, nullable) NSAttributedString *name;
@property (nonatomic, copy, readonly, nullable) NSAttributedString *des;
@property (nonatomic, readonly) BOOL showPausedImageView;
@end
NS_ASSUME_NONNULL_END
