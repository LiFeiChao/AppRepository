//
//  I18NControl.h
//  IntelligenceCommunity
//
//  Created by Aidan on 5/26/14.
//  Copyright (c) 2014 com.ideal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface I18NControl : NSObject

+(NSBundle *)bundle;//获取当前资源文件

+(void)initUserLanguage;//初始化语言文件

+(NSString *)userLanguage;//获取应用当前语言

+(void)setUserlanguage:(NSString *)language;//设置当前语言


@end
