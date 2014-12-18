//
//  Contacts.h
//  IntelligentCommunity
//
//  Created by 高 欣 on 13-7-17.
//  Copyright (c) 2013年 com.ideal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Contacts : NSObject
@property (copy,nonatomic) NSString *userID;
@property (copy,nonatomic) NSString *userName;
@property (copy,nonatomic) NSString *sex;
@property (copy,nonatomic) NSString *avatarUrl;
@property (copy,nonatomic) NSString *mobile;
@property (copy,nonatomic) NSString *email;
@property (copy,nonatomic) NSString *sign;
@property (copy,nonatomic) NSString *brief;
@property (copy,nonatomic) NSString *enterprise;
@property (copy,nonatomic) NSString *department;

@end
