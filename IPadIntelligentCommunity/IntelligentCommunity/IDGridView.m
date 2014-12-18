//
//  IDGridView.m
//  MeetingCloud
//
//  Created by 高 欣 on 12-11-21.
//  Copyright (c) 2012年 Ideal. All rights reserved.
//

#import "IDGridView.h"
#define PageControlH 40
@interface IDGridView(){
    UIScrollView *_scrollView;
    UIPageControl *_pageControl;
}
@end
@implementation IDGridView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self addControls:frame];
    }
    return self;
}

- (void) awakeFromNib
{
    [self addControls:self.frame];
}


#pragma mark -
#pragma mark UIScrollViewDelegate

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if(self.direction==Horizontal){
        _pageControl.currentPage =_scrollView.contentOffset.x / _scrollView.bounds.size.width;
    }else{
        _pageControl.currentPage =_scrollView.contentOffset.y / _scrollView.bounds.size.height;
    }
    //NSLog(@"did scroll to page: %d", _pageControl.currentPage);
}

//#pragma mark UIPageControl action
//
//- (void) pageDidTurn {
//    CGPoint contentOffset = self.scrollView.contentOffset;
//    contentOffset.x  = self.view.bounds.size.width * self.pageControl.currentPage;
//    [self.scrollView setContentOffset:contentOffset animated:YES];
//    NSLog(@"scroll to page: %D", self.pageControl.currentPage);
//}
#pragma mark -
#pragma mark private methods

- (void) didTouchWithTapGestureRecognizer:(UITapGestureRecognizer *)tapGestureRecognizer {
    if (tapGestureRecognizer.state == UIGestureRecognizerStateRecognized &&
        [self.delegate respondsToSelector:@selector(IDGridView:didSelectAtIndex:)]) {
        [self.delegate IDGridView:self didSelectAtIndex:tapGestureRecognizer.view.tag];
    }
}
-(void) click:(id) sender
{
    if ([self.delegate respondsToSelector:@selector(IDGridView:didSelectAtIndex:)]) {
        [self.delegate IDGridView:self didSelectAtIndex:[sender tag]];
    }
}
-(void) addControls:(CGRect) frame;
{
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    _scrollView.showsHorizontalScrollIndicator=NO;
    _scrollView.showsVerticalScrollIndicator=NO;
    _scrollView.pagingEnabled=YES;
    _scrollView.userInteractionEnabled=YES;
    _scrollView.delegate = self;
    [self addSubview:_scrollView];
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, frame.size.height-PageControlH,
                                                                   frame.size.width, PageControlH)];
    _pageControl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _pageControl.hidesForSinglePage = YES;
    _pageControl.currentPage = 0;
    //[pageControl addTarget:self action:@selector(pageDidTurn) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_pageControl];
}

//-(void) setArrayViews:(NSArray *)arrayViews
//{
//    [_arrayViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        [obj removeFromSuperview];
//    }];
//     
//    _arrayViews=arrayViews;
//    [self setNeedsLayout];
//}

-(void) layoutSubviews{
    NSLog(@"layoutSubviews");
    [super layoutSubviews];
    [self layoutViews];
}
-(void) layoutViews
{
    if(!_arrayViews)
        return;

    CGFloat realLayoutWidth=self.frame.size.width-_left*2;
    CGFloat realLayoutHeight=self.frame.size.height-_top-_bottom;
    CGFloat perWOffset=realLayoutWidth/(_col*2);//计算横向每一格得增量
    CGFloat perHOffset=realLayoutHeight/(_row*2);//计算纵向每一格得增量
    CGFloat startWoffset=perWOffset+_left;//起始位置为一个横向增量单位+top
    CGFloat startHoffset=perHOffset+_top;//起始位置为一个横向增量单位+left
    CGFloat wOffset=startWoffset;
    CGFloat hOffset=startHoffset;
    int pageCount=1;
    for (int i=0; i<_arrayViews.count; i++) {
        UIView *view=_arrayViews[i];
        view.center=CGPointMake(wOffset, hOffset);
        view.tag=i;
        if([view isKindOfClass:[UIButton class]]){
            UIButton *btn=(UIButton*)view;
            [btn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
        }else{
            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTouchWithTapGestureRecognizer:)];
            [view addGestureRecognizer:tapGestureRecognizer];
            view.userInteractionEnabled=YES;
        }
        [_scrollView addSubview:view];
        NSLog(@"viewX:%f",view.center.x);
        NSLog(@"viewY:%f",view.center.y);
        
        //计算下一个View的位置
        if((i+1)%(_row*_col)==0){//增加一页
            if(self.direction==Horizontal){
                wOffset=startWoffset+pageCount*self.frame.size.width;
                hOffset=startHoffset;
            }else{
                hOffset=startHoffset+pageCount*self.frame.size.height;
                wOffset=startWoffset;
            }
                
            pageCount++;
            continue;
        }
        if((i+1)%_col==0){//换行
            wOffset=startWoffset+(pageCount-1)*self.frame.size.width;
            hOffset+=perHOffset*2;
        }else{
            wOffset+=perWOffset*2;
        }
    }
    
    //如果view的数量正好为整数页，则pagecount要减1
    pageCount=_arrayViews.count%_row*_col==0?pageCount-1:pageCount;
    CGSize size;
    if(self.direction==Horizontal){
        size=CGSizeMake(_scrollView.frame.size.width*pageCount,
                        self.frame.size.height);
    }else{
        size=CGSizeMake(self.frame.size.width,
                        _scrollView.frame.size.height*pageCount);
    }
    _scrollView.contentSize=size;
    _pageControl.numberOfPages=pageCount;
    _pageControl.hidden=_hidePageControl;
    
}

-(void) scrollToPage:(NSUInteger)index animated:(BOOL) animated;
{
    CGPoint contentOffset;
    if(self.direction==Horizontal){
        contentOffset=CGPointMake(self.frame.size.width*index, 0);
         
    }else{
        contentOffset=CGPointMake(0, self.frame.size.height*index);
    }
    [_scrollView setContentOffset:contentOffset animated:animated];
    _pageControl.numberOfPages=self.arrayViews.count;
    _pageControl.currentPage=index;
}
@end
