//
//  SJAttributesFactory.h
//  SJAttributesFactory
//
//  Created by 畅三江 on 2018/12/10.
//  Copyright © 2018 畅三江. All rights reserved.
//

#ifndef SJAttributesFactory_h
#define SJAttributesFactory_h

#import "SJAttributeWorker.h"

/*!
 *  make attributed string:
 
 *   NSAttributedString *attrStr = sj_makeAttributesString(^(SJAttributeWorker * _Nonnull make) {
 
 *       // set font , text color.
 *       make.font([UIFont boldSystemFontOfSize:14]).textColor([UIColor blackColor]);
 
 *       make.append(@"@迷你世界联机 :@江叔 用小淘气耍赖野人#迷你世界#");
 
 *       make.regexp(@"[@][^@]+\\s", ^(SJAttributesRangeOperator * _Nonnull matched) {
 *           matched.textColor([UIColor purpleColor]);
 *          // some code
 *       });
 
 *       make.regexp(@"[#][^#]+#", ^(SJAttributesRangeOperator * _Nonnull matched) {
 *          matched.textColor([UIColor orangeColor]);
 *          // some code
 *       });
 *   });
 **/
extern NSMutableAttributedString *sj_makeAttributesString(void(^block)(SJAttributeWorker *make));

#endif /* SJAttributesFactory_h */
