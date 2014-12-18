//
//  ImageDetailView.m
//  IntelligentCommunity
//
//  Created by 高 欣 on 13-7-31.
//  Copyright (c) 2013年 com.ideal. All rights reserved.
//

#import "ImageDetailView.h"

@implementation ImageDetailView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super init]){
        [_removeButton addTarget:self action:@selector(closeMe) forControlEvents:UIControlEventTouchUpInside];
        _gridView.col=1;
        _gridView.row=1;
        NSMutableArray *imageViewArray=[[NSMutableArray alloc] init];
        [_imageArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UIImageView *imageView=[[UIImageView alloc] initWithFrame:self.bounds];
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
    }
//    _gridView.alpha=0;
//    
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:0.5f];
//    _gridView.alpha=1.0;
//    [UIView commitAnimations];
    return self;
}
- (void) awakeFromNib
{
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
-(void) closeMe
{
    [UIView animateWithDuration:.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect frame=self.frame;
        frame.origin.x+=self.bounds.size.width;
        self.frame=frame;
    }completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
}
@end
