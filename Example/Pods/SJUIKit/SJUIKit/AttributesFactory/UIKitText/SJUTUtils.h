//
//  SJUTUtils.h
//  LWZAudioModule-LWZAudioModule
//
//  Created by BlueDancer on 2020/12/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT BOOL
SJUTRangeContains(NSRange main, NSRange sub);

FOUNDATION_EXPORT NSRange
SJUTGetTextRange(NSAttributedString *text);

NS_ASSUME_NONNULL_END
