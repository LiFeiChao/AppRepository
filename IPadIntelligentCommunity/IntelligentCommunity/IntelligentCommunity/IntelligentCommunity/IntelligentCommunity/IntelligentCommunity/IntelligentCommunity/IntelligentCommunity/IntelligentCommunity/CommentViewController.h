//
//  CommentViewController.h
//  IntelligenceCommunity
//
//  Created by IdealRD on 13-7-12.
//  Copyright (c) 2013年 com.ideal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Product.h"
#import "EGOTableView.h"
#import "EmoTextView.h"
//#import "HPGrowingTextView.h"

@interface CommentViewController : UIViewController<EmoTextViewDelegate, EGOTableViewDelegate>
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (retain, nonatomic) Product *product;

@end
