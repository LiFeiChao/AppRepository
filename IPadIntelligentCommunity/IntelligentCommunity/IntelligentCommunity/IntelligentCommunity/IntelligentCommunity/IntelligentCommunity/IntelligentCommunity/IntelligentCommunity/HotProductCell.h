//
//  HotProductCell.h
//  IntelligenceCommunity
//
//  Created by 高 欣 on 13-7-16.
//  Copyright (c) 2013年 com.ideal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HotProductCell : UITableViewCell<UIScrollViewDelegate>{
    IBOutlet UIScrollView *_scrollView;
    IBOutlet UIPageControl *_pageControl;
    NSArray *_hotProductArray;
}
@property (copy,nonatomic) NSArray *hotProductArray;
@end
