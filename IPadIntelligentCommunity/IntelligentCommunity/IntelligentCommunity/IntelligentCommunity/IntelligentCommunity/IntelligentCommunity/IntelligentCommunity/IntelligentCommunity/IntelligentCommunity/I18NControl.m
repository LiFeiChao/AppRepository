//
//  I18NControl.m
//  IntelligenceCommunity
//
//  Created by Aidan on 5/26/14.
//  Copyright (c) 2014 com.ideal. All rights reserved.
//

#import "I18NControl.h"

@implementation I18NControl

static NSBundle *bundle = nil;

+ ( NSBundle * )bundle{
    
    return bundle;
    
}

+(void)initUserLanguage{
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    NSString *string = [def valueForKey:@"userLanguage"];
    
    if(string.length == 0){
        
        //获取系统当前语言版本(中文zh-Hans,英文en)
        
        NSArray* languages = [def objectForKey:@"AppleLanguages"];
        
        NSString *current = [languages objectAtIndex:0];
        
        string = current;
        
        [def setValue:current forKey:@"userLanguage"];
        
        [def synchronize];//持久化，不加的话不会保存
    }
    
    //获取文件路径
    NSString *path = [[NSBundle mainBundle] pathForResource:string ofType:@"lproj"];
    
    bundle = [NSBundle bundleWithPath:path];//生成bundle
    
    
}

+(NSString *)userLanguage{
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    NSString *language = [def valueForKey:@"userLanguage"];
    
    return language;
}

+(void)setUserlanguage:(NSString *)language{
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    //1.第一步改变bundle的值
    NSString *path = [[NSBundle mainBundle] pathForResource:language ofType:@"lproj" ];
    
    bundle = [NSBundle bundleWithPath:path];
    
    //2.持久化
    [def setValue:language forKey:@"userLanguage"];
    
    [def synchronize];
}

@end
