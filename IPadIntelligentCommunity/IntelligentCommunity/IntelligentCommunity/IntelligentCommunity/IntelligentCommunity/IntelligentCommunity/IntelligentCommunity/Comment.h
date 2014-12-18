//
//  Comment.h
//  IntelligenceCommunity
//
//  Created by 高 欣 on 12-11-8.
//  Copyright (c) 2012年 Ideal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Comment : NSObject
@property (nonatomic,copy) NSString* commentID;
@property (nonatomic,copy) NSString* content;
@property (nonatomic,copy) NSString* createTime;
@property (nonatomic,strong) User* submitUser;

@end

