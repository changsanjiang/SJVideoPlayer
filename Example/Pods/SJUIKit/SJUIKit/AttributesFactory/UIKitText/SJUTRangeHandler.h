//
//  SJUTRangeHandler.h
//  AttributesFactory
//
//  Created by 畅三江 on 2019/4/13.
//  Copyright © 2019 SanJiang. All rights reserved.
//

#import "SJUIKitAttributesDefines.h"
@class SJUTRangeRecorder;

NS_ASSUME_NONNULL_BEGIN
@interface SJUTRangeHandler : NSObject<SJUTRangeHandlerProtocol>
- (instancetype)initWithRange:(NSRange)range;
@property (nonatomic, strong, readonly) SJUTRangeRecorder *recorder;
@end

@interface SJUTRangeRecorder : NSObject
@property (nonatomic) NSRange range;
@property (nonatomic, strong, nullable) id<SJUTAttributesProtocol> utOfReplaceWithString;
@property (nonatomic, copy, nullable) void(^replaceWithText)(id<SJUIKitTextMakerProtocol> make);
@property (nonatomic, copy, nullable) void(^update)(id<SJUTAttributesProtocol> make);
@end
NS_ASSUME_NONNULL_END
