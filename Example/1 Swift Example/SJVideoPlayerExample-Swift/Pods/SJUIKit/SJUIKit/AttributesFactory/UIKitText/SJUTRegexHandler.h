//
//  SJUTRegexHandler.h
//  AttributesFactory
//
//  Created by 畅三江 on 2019/4/12.
//  Copyright © 2019 SanJiang. All rights reserved.
//

#import "SJUIKitAttributesDefines.h"
@class SJUTRegexRecorder;

NS_ASSUME_NONNULL_BEGIN
@interface SJUTRegexHandler : NSObject<SJUTRegexHandlerProtocol>
- (instancetype)initWithRegex:(NSString *)regex;
@property (nonatomic, strong, readonly) SJUTRegexRecorder *recorder;
@end

@interface SJUTRegexRecorder : NSObject
@property (nonatomic) NSRegularExpressionOptions regularExpressionOptions;
@property (nonatomic) NSMatchingOptions matchingOptions;
@property (nonatomic, strong, nullable) id<SJUTAttributesProtocol> utOfReplaceWithString;
@property (nonatomic, copy, nullable) NSString *regex;
@property (nonatomic, copy, nullable) void(^replaceWithText)(id<SJUIKitTextMakerProtocol> make);
@property (nonatomic, copy, nullable) void(^update)(id<SJUTAttributesProtocol> make);
@property (nonatomic, copy, nullable) void(^handler)(NSMutableAttributedString *attrStr, NSTextCheckingResult *result);
@end
NS_ASSUME_NONNULL_END
