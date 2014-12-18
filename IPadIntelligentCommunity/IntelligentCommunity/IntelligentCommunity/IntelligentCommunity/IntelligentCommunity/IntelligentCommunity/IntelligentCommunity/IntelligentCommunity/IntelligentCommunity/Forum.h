//
//  Forum.h
//  IntelligenceCommunity
//
//  Created by IdealRD on 13-7-19.
//  Copyright (c) 2013年 com.ideal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Forum : NSObject

@property (nonatomic,copy) NSString* postID;                // 帖子ID
@property (nonatomic,copy) NSString* title;                 // 帖子标题	
@property (nonatomic,strong) User* submitUser;              // 发表用户信息
@property (nonatomic,strong) User* lastReplyUser;           // 最后回复用户
@property (nonatomic,copy) NSString* createTime;            // 发表时间
@property (nonatomic,copy) NSString* lastReplyTime;         // 最后回复时间
@property (nonatomic) int viewCount;                        // 帖子查看数
@property (nonatomic) int replyCount;                       // 帖子回复数

@end

