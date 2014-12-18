//
//  ActionLabel.h
//  BestPay
//
//  Created by 高 欣 on 12-3-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
@interface ActionLabel : UILabel<MFMailComposeViewControllerDelegate>
@property (nonatomic,copy) NSString *type;
@end
