//
//  DataManager.m
//  IDEAL_TYSX
//
//  Created by 高 欣 on 11-12-29.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//
#define degreesToRadian(x) (M_PI * (x) / 180.0)


#import "AppController.h"
#import "AppDelegate.h"
#import "FConstants.h"
#import "I18NControl.h"


@interface AppController ()  <MBProgressHUDDelegate>

@end

@implementation AppController

@synthesize navigationController = _navigationController,HUD = _HUD;
@synthesize filterCategoryID;

static AppController *appController = nil;


+ (AppController *)sharedInstance
{
    if (appController == nil)
    {
        //appController = [NSAllocateObject([self class], 0, NULL) init];
        appController=[[AppController alloc] init];
        
        //appController.userInfo=[[UserInfo alloc] init];
    }
    
    return appController;
}


- (void)setNavigationBackImage:(NSString *)navigationBackImage
{
    _navigationBackImage=navigationBackImage;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>4.9) {
        [appController.navigationController.navigationBar setBackgroundImage:
         [UIImage imageNamed:_navigationBackImage] forBarMetrics:UIBarMetricsDefault];
    } else{
        [appController.navigationController.navigationBar setNeedsDisplay];
    }
}


- (NSString *)getNavigationBackImage
{
    return _navigationBackImage;
}

- (void)startWithNavigationController:(UINavigationController *)controller {
    self.navigationController=controller;
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(showWithLabel:) name:DFNotificationShowLoading object:nil];
    [notificationCenter addObserver:self selector:@selector(hideHUD) name:DFNotificationHideLoading object:nil];
}

- (void)showWithLabel
{
    if(!_HUD){
        _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    }
    
    [[[UIApplication sharedApplication] delegate].window addSubview:_HUD];
    //	[self.navigationController.view addSubview:_HUD];
    //    [self.navigationController.view bringSubviewToFront:_HUD];
    _HUD.delegate = self;
    _HUD.labelText = [[I18NControl bundle] localizedStringForKey:@"Wait" value:nil table:nil];
    [_HUD show:YES];
    //[_HUD showWhileExecuting:@selector(myTask) onTarget:self withObject:nil animated:YES];
    //[self.HUD release];
}
- (void)showWithLabel:(NSNotification *)note
{
    NSString *text=nil;
    if(note){
        text = [[note userInfo] objectForKey:@"Text"];
    }
    if(!text){
        text=[[I18NControl bundle] localizedStringForKey:@"Wait" value:nil table:nil];
    }
    if(!_HUD){

        _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    }
    [[[UIApplication sharedApplication] delegate].window addSubview:_HUD];
    _HUD.delegate = self;
    

    

    _HUD.center = CGPointMake([[UIApplication sharedApplication] delegate].window.frame.size.width /2, [[UIApplication sharedApplication] delegate].window.frame.size.height / 2);
    
//    _HUD.transform = CGAffineTransformMakeRotation(degreesToRadian(90));
    if ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft ) {
        float angle = 90;
        _HUD.transform = CGAffineTransformMakeRotation(degreesToRadian(angle));
    } else if ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight){
        float angle = -90;
        _HUD.transform = CGAffineTransformMakeRotation(degreesToRadian(angle));
    }else if ([UIDevice currentDevice].orientation == UIDeviceOrientationPortraitUpsideDown){
        float angle = 180;
        _HUD.transform = CGAffineTransformMakeRotation(degreesToRadian(angle));
        
    }else{
        float angle =  90;
        _HUD.transform = CGAffineTransformMakeRotation(degreesToRadian(angle));
    }
    
    _HUD.labelText = text;
    
    
    [_HUD show:YES];
}

- (void)hideHUD
{
    [_HUD removeFromSuperview];
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud
{
    // Remove HUD from screen when the HUD was hidded
    [_HUD removeFromSuperview];
	self.HUD = nil;
}

/*- (void)dealloc {
 
 [_HUD release];
 [appController release];
 [super dealloc];
 }*/

@end
