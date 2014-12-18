//
//  ForumDetialViewController.h
//  IntelligenceCommunity
//
//  Created by IdealRD on 13-7-17.
//  Copyright (c) 2013年 com.ideal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOTableView.h"
#import "PostCellDelegate.h"
#import "IDGridView.h"
#import "ForumEditViewController.h"
@interface ForumDetialViewController : UIViewController<EGOTableViewDelegate,PostCellDelegate>
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic,copy) NSString* postID;                // 帖子ID
@property (strong,nonatomic) ForumEditViewController *forumEditVC;

-(void) addForum;
@end
