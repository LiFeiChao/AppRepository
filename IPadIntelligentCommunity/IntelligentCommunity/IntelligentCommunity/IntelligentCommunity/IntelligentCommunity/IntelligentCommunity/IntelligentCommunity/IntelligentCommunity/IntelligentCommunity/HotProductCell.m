//
//  HotProductCell.m
//  IntelligenceCommunity
//
//  Created by 高 欣 on 13-7-16.
//  Copyright (c) 2013年 com.ideal. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "HotProductCell.h"
#import "Product.h"
#import "UIImageView+AFNetworking.h"
#import "UIButton+Title.h"

#define kPageSize 3.0f
#define kImageSize CGSizeMake(60, 60)
#define kFont [UIFont systemFontOfSize:13.0f]
@implementation HotProductCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) setHotProductArray:(NSArray *)hotProductArray
{
    _hotProductArray=hotProductArray;
    CGFloat perWidth=self.bounds.size.width/(kPageSize*2);
    __block CGFloat centerX=perWidth;
    CGFloat centerY=self.bounds.size.height/2-16;
    [_hotProductArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Product *product=obj;
        UIImageView *productImage=[[UIImageView alloc] initWithFrame:(CGRect){CGPointZero,kImageSize}];
        productImage.center=CGPointMake(centerX, centerY);
        productImage.tag=idx;
        productImage.userInteractionEnabled=YES;
        productImage.layer.cornerRadius=8.0f;
        productImage.layer.masksToBounds=YES;
        UITapGestureRecognizer *imageTap= [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected:)];
        [productImage addGestureRecognizer:imageTap];
        UILabel *productLabel=[[UILabel alloc] initWithFrame:(CGRect){CGPointZero,perWidth*2,20}];
        productLabel.center=CGPointMake(centerX, centerY+40);
        
        [productImage setImageWithURL:[NSURL URLWithString:product.imageUrl] placeholderImage:[UIImage imageNamed:DefaultImage]];
        productLabel.backgroundColor=[UIColor clearColor];
        productLabel.text=product.productName;
        productLabel.font=kFont;
        productLabel.textAlignment=UITextAlignmentCenter;
        [_scrollView addSubview:productImage];
        [_scrollView addSubview:productLabel];
        centerX+=perWidth*2;
    }];
    int pageCount=(int)ceilf(hotProductArray.count/kPageSize);
    _pageControl.hidden=pageCount<=1;
    _pageControl.numberOfPages=pageCount;
    _pageControl.currentPage=0;
    _scrollView.contentSize=CGSizeMake(self.bounds.size.width*pageCount,self.bounds.size.height);

}
#pragma mark - UIScrollViewDelegate Method
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _pageControl.currentPage = scrollView.contentOffset.x / scrollView.bounds.size.width;
}


- (void)tapDetected:(UIGestureRecognizer *)sender {
    // Code to respond to gesture here
    UIView *tapView = sender.view;
    Product *product=_hotProductArray[tapView.tag];
    [[NSNotificationCenter defaultCenter] postNotificationName:DFNotificationHotProductTaped object:self userInfo:@{@"value":product}];
    
}
@end
