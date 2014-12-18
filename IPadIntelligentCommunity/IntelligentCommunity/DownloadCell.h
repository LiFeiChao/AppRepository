//
//  DownloadCell.h
//  IntelligenceCommunity
//
//  Created by IdealRD on 13-7-30.
//  Copyright (c) 2013年 com.ideal. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "Download.h"


@interface DownloadCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIProgressView *proView;
//@property (strong, nonatomic) IBOutlet UIButton *btnDownload;
//@property (strong, nonatomic) IBOutlet UIButton *btnDelete;

@property (strong, nonatomic) IBOutlet UILabel *docStatus;

@property (strong, nonatomic) Download *download;
@property (nonatomic, copy) NSString *productID;
@end
