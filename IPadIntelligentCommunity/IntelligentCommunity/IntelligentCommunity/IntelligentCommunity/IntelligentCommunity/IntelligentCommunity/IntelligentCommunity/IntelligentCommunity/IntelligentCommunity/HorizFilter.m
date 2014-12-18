//
//  HorizFilter.m
//  IntelligenceCommunity
//
//  Created by IdealRD on 13-7-9.
//  Copyright (c) 2013年 com.ideal. All rights reserved.
//

#import "HorizFilter.h"

#define kButtonBaseTag 10000
#define kLeftOffset 10


@implementation HorizFilter

@synthesize titles = _titles;
@synthesize selectedImage = _selectedImage;
@synthesize itemSelectedDelegate;
@synthesize dataSource;
@synthesize itemCount = _itemCount;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.bounces = YES;
        self.scrollEnabled = YES;
        self.alwaysBounceHorizontal = YES;
        self.alwaysBounceVertical = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        
        [self reloadData];
    }
    return self;
}

-(void) awakeFromNib
{
    self.bounces = YES;
    self.scrollEnabled = YES;
    self.alwaysBounceHorizontal = YES;
    self.alwaysBounceVertical = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    
    [self reloadData];
}

-(void) reloadData
{
    self.itemCount = [dataSource numberOfItemsForMenu:self];
    self.backgroundColor = [dataSource backgroundColorForMenu:self];
    self.selectedImage = [dataSource selectedItemImageForMenu:self];
    
    UIFont *buttonFont = [UIFont systemFontOfSize:15];
    int buttonPadding = 20;
    
    int tag = kButtonBaseTag;
    int xPos = kLeftOffset;
    
    // 删除所有button
    for(UIButton *view in [self subviews]){
        [view removeFromSuperview];
    }
    
    for(int i = 0 ; i < self.itemCount; i ++)
    {
        NSString *title = [dataSource horizMenu:self titleForItemAtIndex:i];
        UIButton *customButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [customButton setTitle:title forState:UIControlStateNormal];
        customButton.titleLabel.font = buttonFont;
        
        // 字体颜色
        [customButton setTitleColor:DefaultTagColor_N forState:UIControlStateNormal];
        [customButton setTitleColor:DefaultTagColor_S forState:UIControlStateSelected];
        
  //    [customButton setBackgroundImage:self.selectedImage forState:UIControlStateSelected];
        
        customButton.tag = tag++;
        [customButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        int buttonWidth = [title sizeWithFont:customButton.titleLabel.font
                            constrainedToSize:CGSizeMake(150, 28)
                                lineBreakMode:UILineBreakModeClip].width;
        
        customButton.frame = CGRectMake(xPos, 4, buttonWidth + buttonPadding, 28);
        xPos += buttonWidth;
        xPos += buttonPadding;
        [self addSubview:customButton];
    }

//  self.contentSize = CGSizeMake(xPos, 41);
    self.contentSize = CGSizeMake(xPos, self.frame.size.height);
    [self layoutSubviews];
}


-(void) setSelectedIndex:(int) index animated:(BOOL) animated
{
    UIButton *thisButton = (UIButton*) [self viewWithTag:index + kButtonBaseTag];
    thisButton.selected = YES;
    [self setContentOffset:CGPointMake(thisButton.frame.origin.x - kLeftOffset, 0) animated:animated];
    [self.itemSelectedDelegate horizMenu:self itemSelectedAtIndex:index];
}

-(void) buttonTapped:(id) sender
{
    UIButton *button = (UIButton*) sender;
    
    for(int i = 0; i < self.itemCount; i++)
    {
        UIButton *thisButton = (UIButton*) [self viewWithTag:i + kButtonBaseTag];
        if(i + kButtonBaseTag == button.tag)
            thisButton.selected = YES;
        else
            thisButton.selected = NO;
    }
    
    [self.itemSelectedDelegate horizMenu:self itemSelectedAtIndex:button.tag - kButtonBaseTag];
}


- (void)dealloc
{
    [_selectedImage release];
    _selectedImage = nil;
    [_titles release];
    _titles = nil;
    
    [super dealloc];
}

@end
