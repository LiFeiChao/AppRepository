//
//  ImageDetailViewController.m
//  IntelligentCommunity
//
//  Created by 高 欣 on 13-7-31.
//  Copyright (c) 2013年 com.ideal. All rights reserved.
//

#import "ImageDetailViewController.h"
#import "IDGridView.h"
@interface ImageDetailViewController (){
    IBOutlet IDGridView *_gridView;
    IBOutlet UIButton *_removeButton;
    
}

-(IBAction) removeMe:(id) sender;
@end

@implementation ImageDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _gridView.col=1;
    _gridView.row=1;
    NSMutableArray *imageViewArray=[[NSMutableArray alloc] init];
    [_imageArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIImageView *imageView=[[UIImageView alloc] initWithFrame:self.view.bounds];
        imageView.tag=idx;
        imageView.userInteractionEnabled=YES;
        imageView.contentMode=UIViewContentModeScaleAspectFit;
        [imageView setImageWithURL:[NSURL URLWithString:obj] placeholderImage:nil];
        [imageViewArray addObject:imageView];
    }];
    _gridView.arrayViews=imageViewArray;
    _gridView.direction=Horizontal;
    _gridView.backgroundColor=[UIColor blackColor];
    [_gridView scrollToPage:self.index animated:NO];
//_gridView.alpha=0;
   
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:0.5f];
//    _gridView.alpha=1.0;
//    [UIView commitAnimations];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction) removeMe:(id) sender
{
    [UIView animateWithDuration:.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect frame=self.view.frame;
        frame.origin.x+=self.view.bounds.size.width;
        self.view.frame=frame;
    }completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
     
}

@end
