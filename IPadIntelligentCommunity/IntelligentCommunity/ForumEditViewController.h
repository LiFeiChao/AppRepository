//
//  ForumEditViewController.h
//  IntelligenceCommunity
//
//  Created by IdealRD on 13-7-17.
//  Copyright (c) 2013年 com.ideal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FConstants.h"
#import "PostDetail.h"
#import "QBImagePickerController.h"
#import "IDGridView.h"
#import "TSEmojiView.h"
typedef enum {
    AddPost = 0,
	ReplyPost,
	EditPost,
    EditReply
} PostsEditType;
@interface ForumEditViewController : UIViewController<QBImagePickerControllerDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate,
TSEmojiViewDelegate, IDGridViewDelegate>
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic) PostsEditType postType;               // 编辑类型
@property (nonatomic,strong) PostDetail *postDetail;        // 帖子信息

@property (strong, nonatomic) IBOutlet UIBarButtonItem *submitButtonItem;

@end
