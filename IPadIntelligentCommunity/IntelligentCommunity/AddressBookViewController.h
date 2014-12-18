//
//  AddressBookViewController.h
//  IntelligentCommunity
//
//  Created by 高 欣 on 13-7-12.
//  Copyright (c) 2013年 com.ideal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSplitViewController.h"
@interface AddressBookViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    UIButton *btnRefresh;
}
@property (assign,nonatomic) MGSplitViewController *splitVC;
@property (strong,nonatomic) IBOutlet UITableView *subTableView;

@property (strong,nonatomic) UIButton *btnRefresh;
@end
