//
//  HotProductViewController.m
//  IntelligentCommunity
//
//  Created by 高 欣 on 13-9-2.
//  Copyright (c) 2013年 com.ideal. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "HotProductViewController.h"
#import "DetailViewController.h"
#import "Product.h"
#import "ProductView.h"
#import "Util.h"
#import "UIView+NibLoading.h"
#import "ProductDetailViewController.h"
#import "I18NControl.h"
 
#define kMaxRowCount 4
#define kRowHeight 115

#define CLOSE_MASKVIEW @"close_maskView"
#define HOTVIEWCONTROLLER_CLOSE_MASKVIEW @"hotViewController_close_maskView"
#define degreesToRadian(x) (M_PI * (x) / 180.0)

@interface HotProductViewController (){
    IBOutlet IDGridView *_hotProductGridView;
}
@property (strong,nonatomic) UIView *maskView;
@property (strong,nonatomic) NSMutableArray *hotProductArray;

@end

UIView *detailView;
UIView *lineView;

@implementation HotProductViewController

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
    
    self.label.text = [[I18NControl bundle]localizedStringForKey:@"hotProduct" value:nil table:nil];
    // Do any additional setup after loading the view from its nib.
    self.hotProductArray=[NSMutableArray array];
    _hotProductGridView.col=4;
    
    _hotProductGridView.left=0;
    _hotProductGridView.top=5;
    _hotProductGridView.bottom=5;
    _hotProductGridView.hidePageControl=YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeDetailVC) name:CLOSE_MASKVIEW object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeMaskView) name:HOTVIEWCONTROLLER_CLOSE_MASKVIEW object:nil];
    
    [self getHotProduct];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillDisappear:(BOOL)animated
{
    detailView = nil;
    lineView = nil;
}

#pragma mark -
#pragma mark IDGridViewDelegate method
-(void)IDGridView:(IDGridView *)IDGridView didSelectAtIndex:(NSUInteger)index
{
    for (UIView *view in _maskView.subviews) {
        [view removeFromSuperview];
    }
    
    Product *product=_hotProductArray[index];
    self.detailViewController = [[ProductDetailViewController alloc] initWithNibName:@"ProductDetailViewController" bundle:nil];
    
    self.detailViewController.productInfo = product;
    
    if(!self.maskView){
        self.maskView=[[UIView alloc] initWithFrame:(CGRect){self.view.bounds.size.width, 0,447,748}];
        
        _maskView.backgroundColor=RGBColor(239, 241, 243);
        [[_maskView layer] setShadowOffset:CGSizeMake(-2, 2)];
        
        [[_maskView layer] setShadowOpacity:.5];
        [[_maskView layer] setShadowColor:[UIColor blackColor].CGColor];
    }
    
    detailView=self.detailViewController.view;
    detailView.frame=(CGRect){-1 , 0,447,748};
    
    [_maskView addSubview:detailView];
    [self.view  addSubview:_maskView];
    
    [UIView animateWithDuration:.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _maskView.frame=(CGRect){ -1,0,447,748};
    }completion:nil];
}

#pragma mark -
#pragma mark Custom method
-(void) getHotProduct
{
    NSDictionary *dicParams=@{@"userID":[AppController sharedInstance].userInfo.userID,
                              @"language":[Util getCurrentLanguage]};
    
//    NSLog(@"当前语言是 %@", [Util getCurrentLanguage]);
    
    [[AFIntelligentCommunityClient sharedClient] getPath:@"productInterface/getHotProductList" parameters:dicParams success:^(AFHTTPRequestOperation *operation, id JSON) {
        CLog(@"%@",JSON);
        
        NSArray *arrayAllProduct=JSON;
        [_hotProductArray removeAllObjects];
         NSMutableArray *arrayViews=[[NSMutableArray alloc] init];
        [arrayAllProduct enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *dicProduct=obj;
            Product *product=[[Product alloc] init];
            product.productID=dicProduct[@"productID"];
            product.productName=dicProduct[@"productName"];
            product.briefIntroduction=dicProduct[@"briefIntroduction"];
            product.imageUrl=dicProduct[@"iconURL"];
            NSArray *arrayCategory=dicProduct[@"categoryArray"];
            NSMutableArray *arrayCategoryID=[[NSMutableArray alloc] init];
            NSMutableString *categoryIDString=[[NSMutableString alloc] init];
            [arrayCategory enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [arrayCategoryID addObject:arrayCategory[idx][@"categoryID"]];
                [categoryIDString appendString:arrayCategory[idx][@"categoryID"]];
                [categoryIDString appendString:@","];
            }];
            
            product.categoryArray=arrayCategoryID;
            product.categoryString=categoryIDString;
            
            ProductView *productView=(ProductView*)[ProductView loadInstanceFromNib];
            productView.product=product;
            [arrayViews addObject:productView];
             
            [_hotProductArray addObject:product];
            
        }];
        int rowCount=(int)_hotProductArray.count/_hotProductGridView.col;
        if(_hotProductArray.count%_hotProductGridView.col!=0){
            rowCount+=1;
        }
        
        if(rowCount>kMaxRowCount){
            rowCount=kMaxRowCount;
            _hotProductGridView.hidePageControl=NO;
        }
        _hotProductGridView.row=rowCount;
        CGRect frame = _hotProductGridView.frame;
        
        frame.size.height=rowCount*kRowHeight;
        frame.size.width = 410;
        _hotProductGridView.frame=frame;
        
        _hotProductGridView.arrayViews=arrayViews;
        [_hotProductGridView setNeedsLayout];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Util failOperation:operation.responseData]; 
    }];
}
-(void) closeDetailVC
{
    //UIView *detailView=self.detailViewController.view;
  
    
    [UIView animateWithDuration:.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _maskView.frame=(CGRect){self.view.bounds.size.width,0,447,748};
    }completion:^(BOOL finished) {
//        [self.detailViewController.view removeFromSuperview];
        [_maskView removeFromSuperview];
    }];
}

- (void) closeMaskView
{
    [_maskView removeFromSuperview];
}
@end
