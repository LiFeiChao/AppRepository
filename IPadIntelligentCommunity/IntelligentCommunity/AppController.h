//
//  DataManager.h
//  IDEAL_TYSX
//
//  Created by 高 欣 on 11-12-29.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"
#import "User.h"
 
@interface AppController : NSObject{
    NSString* _navigationBackImage;
    
}

@property (nonatomic, readwrite, retain) UINavigationController *navigationController;
@property (nonatomic,retain) MBProgressHUD *HUD;

@property (nonatomic,retain) User *userInfo;
@property NSString * filterCategoryID;

- (void)setNavigationBackImage:(NSString *)navigationBackImage;

- (NSString *)getNavigationBackImage;
- (void) startWithNavigationController:(UINavigationController *)navigationController;
+ (AppController  * ) sharedInstance;
@end
