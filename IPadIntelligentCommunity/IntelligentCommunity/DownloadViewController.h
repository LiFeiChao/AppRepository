//
//  DownloadViewController.h
//  IntelligenceCommunity
//
//  Created by 王飞 on 14-6-1.
//  Copyright (c) 2014年 com.ideal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownloadDetailViewController.h"



@interface DownloadViewController : UIViewController<UITableViewDataSource
, UITableViewDelegate>
{

}
@property (strong, nonatomic) IBOutlet UITableView *tableview;

@property NSArray* docLibTypeArray;

@property NSArray* docArray;


@end
