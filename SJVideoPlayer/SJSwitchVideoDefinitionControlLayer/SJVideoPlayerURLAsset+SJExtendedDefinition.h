//
//  SJVideoPlayerURLAsset+SJExtendedDefinition.h
//  Pods
//
//  Created by 畅三江 on 2019/7/12.
//

#import "SJVideoPlayerURLAsset.h"

NS_ASSUME_NONNULL_BEGIN

@interface SJVideoPlayerURLAsset (SJExtendedDefinition)

/// e.g. 高清 720P
@property (nonatomic, copy, nullable) NSString *definition_fullName;

/// e.g. 720P
@property (nonatomic, copy, nullable) NSString *definition_lastName;

@end

NS_ASSUME_NONNULL_END
