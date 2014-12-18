//
//  DetailViewController.h
//  IntelligenceCommunity
//
//  Created by 高 欣 on 13-4-9.
//  Copyright (c) 2013年 com.ideal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Product.h"


@interface DetailViewController : UIViewController<UITextFieldDelegate, UIDocumentInteractionControllerDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (retain, nonatomic) Product *product;

//@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UITextField *txtTag;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (assign, nonatomic) BOOL isPop;
- (IBAction)decreaseFont:(id)sender;
- (IBAction)increaseFont:(id)sender;

- (IBAction)editTag:(id)sender;
- (IBAction)submitTag:(id)sender;

@end
