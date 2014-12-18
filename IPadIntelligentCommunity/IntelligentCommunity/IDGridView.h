//
//  IDGridView.h
//  MeetingCloud
//
//  Created by 高 欣 on 12-11-21.
//  Copyright (c) 2012年 Ideal. All rights reserved.
//

#import <UIKit/UIKit.h>
@class IDGridView;
@protocol IDGridViewDelegate <NSObject>
@optional
-(void)IDGridView:(IDGridView *)IDGridView didSelectAtIndex:(NSUInteger)index;
@end
typedef enum {
    Horizontal,     
    Vertical 
} Direction;
@interface IDGridView : UIView<UIScrollViewDelegate>
@property (nonatomic,unsafe_unretained) IBOutlet id<IDGridViewDelegate> delegate;
@property (nonatomic,strong) NSArray *arrayViews;
@property (nonatomic,assign) NSInteger row;
@property (nonatomic,assign) NSInteger col;
@property (nonatomic,assign) CGFloat top;//上间距
@property (nonatomic,assign) CGFloat bottom;//下间距
@property (nonatomic,assign) CGFloat left;//左间距和右间距一样
@property (nonatomic,assign) BOOL hidePageControl;
@property (nonatomic,assign) Direction direction;
 
-(void) scrollToPage:(NSUInteger)index animated:(BOOL) animated;

@end
