//
//  AppDelegate.m
//  IntelligentCommunity
//
//  Created by 高 欣 on 13-4-9.
//  Copyright (c) 2013年 com.ideal. All rights reserved.
//

#import "AppDelegate.h"
#import "FConstants.h"
#import "LoginViewController.h"
#import "IAlertView.h"
#import "Util.h"
#import "iToast.h"
#import "I18NControl.h"

//#import "MasterViewController.h"

@implementation AppDelegate
@synthesize managedObjectModel=_managedObjectModel, managedObjectContext=_managedObjectContext, persistentStoreCoordinator=_persistentStoreCoordinator;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    //版本更新
    [NSThread detachNewThreadSelector:@selector(updateVersion) toTarget:self withObject:nil];
    //[self updateVersion];
    //让欢迎页显示的更久并让程序能有充分时间检测版本
    
    [NSThread sleepForTimeInterval:1.2f];
    LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
    self.navigationController.navigationBarHidden=YES;
    self.window.rootViewController = self.navigationController;
    [[AppController sharedInstance] startWithNavigationController:self.navigationController];
    [[UINavigationBar appearance] setBackgroundImage:
         [[UIImage imageNamed:DefaultNavigationBackImage] stretchableImageWithLeftCapWidth:4 topCapHeight:0] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTintColor:DefaultNavigationTintColor];
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                UITextAttributeTextColor: [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0],
                          UITextAttributeTextShadowColor: [UIColor whiteColor],
                         UITextAttributeTextShadowOffset:[NSValue valueWithUIOffset:UIOffsetMake(0, 0)]
                          
     }];
    self.window.backgroundColor=[UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    
//    NSDictionary *dicParams=@{@"clientType":@"1",
//                              @"content":@"哈哈哈哈",
//                              @"pictures":@"",
//                              @"submitUserID":@"08325d6174be42d6ab7ab5d5bd402448",
//                              @"title":@"的淡淡的"
//                              };
//    [[AFIntelligentCommunityClient sharedClient] postPath:@"" parameters:dicParams success:^(AFHTTPRequestOperation *operation, id JSON) {
//        [[iToast makeText:@"提交成功"] setGravity:iToastGravityCenter];
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        [[iToast makeText:@"提交失败"] setGravity:iToastGravityCenter];
//    }];
//    NSDictionary *dicParams=@{@"clientType":@"1",
//                              @"content":@"哈哈哈哈",
//                              @"pictures":@"",
//                              @"submitUserID":@"08325d6174be42d6ab7ab5d5bd402448",
//                              @"title":@"的淡淡的"
//                              };
//    [[AFIntelligentCommunityClient sharedClient] postPath:@"" parameters:dicParams success:^(AFHTTPRequestOperation *operation, id JSON) {
//        [[iToast makeText:@"提交成功"] setGravity:iToastGravityCenter];
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        [[iToast makeText:@"提交失败"] setGravity:iToastGravityCenter];
//    }];
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [self saveContext];
}
- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString* token = [NSString stringWithFormat:@"%@",deviceToken];
    token = [[token description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token=[token stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"apns -> 生成的devToken:%@", token);
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:DeviceToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
    //提交deviceToken到服务器
}

- (void)application:(UIApplication *)application
didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    [[[iToast makeText:[[I18NControl bundle] localizedStringForKey:@"cannotGetDeviceID" value:nil table:nil]]  setGravity:iToastGravityCenter] show];
    NSLog(@"注册失败，无法获取设备ID, 具体错误: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)payload
{
    NSLog(@"remote notification: %@",[payload description]);
   
    NSString* alertStr = nil;
    NSDictionary *apsInfo = [payload objectForKey:@"aps"];
    NSObject *alert = [apsInfo objectForKey:@"alert"];
    if ([alert isKindOfClass:[NSString class]])
    {
        alertStr = (NSString*)alert;
    }
    else if ([alert isKindOfClass:[NSDictionary class]])
    {
        NSDictionary* alertDict = (NSDictionary*)alert;
        alertStr = [alertDict objectForKey:@"body"];
    }
    application.applicationIconBadgeNumber = [[apsInfo objectForKey:@"badge"] integerValue];
    if ([application applicationState] == UIApplicationStateActive && alertStr != nil)
    {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:[[I18NControl bundle] localizedStringForKey:@"msgPush" value:nil table:nil] message:alertStr delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [self saveContext];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self saveContext];
}

#if __IPAD_OS_VERSION_MAX_ALLOWED >= __IPAD_6_0

//- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
//{
//    
//    return UIInterfaceOrientationMaskAll;
//    
//    
//}
#endif
- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            CLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}
#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"IntelligentCommunity" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"IntelligentCommunity.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        CLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}
#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


// 版本更新
- (void)updateVersion{
    // 获取当前版本号
    NSString *curVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    CLog(@"CFBundleVersion: %@", curVersion);
    __block NSString *latestVersion;
    __block NSString *downloadURL;
    NSDictionary *dicParams=@{@"clientType":ClientType};
    [[AFIntelligentCommunityClient sharedClient] getPath:@"ClientInterface/getLatestVersion" parameters:dicParams success:^(AFHTTPRequestOperation *operation, id JSON) {
        CLog(@"%@",JSON);
        NSDictionary *retDict=JSON;
        // 最新版本号
        latestVersion = [retDict objectForKey:@"version"];
        // 下载地址
        downloadURL = [retDict objectForKey:@"downloadURL"];
        
        if ([curVersion compare:latestVersion] != NSOrderedSame){
            IAlertView *alertView=[[IAlertView alloc] initWithTitle:[[I18NControl bundle] localizedStringForKey:@"projectName" value:nil table:nil] message:[[I18NControl bundle] localizedStringForKey:@"newEditionMsg" value:nil table:nil]];
            [alertView addButtonWithTitle:[[I18NControl bundle] localizedStringForKey:@"confirm" value:nil table:nil] callback:^(int index, NSString *title) {
                UIApplication *application = [UIApplication sharedApplication];
                [application openURL:[NSURL URLWithString:downloadURL]];
            }];
            [alertView addButtonWithTitle:[[I18NControl bundle] localizedStringForKey:@"cancel" value:nil table:nil] callback:nil];
            [alertView show];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Util failOperation:operation.responseData];
    }];
}

@end
