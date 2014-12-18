//
//  HorizFilter.h
//  IntelligenceCommunity
//
//  Created by IdealRD on 13-7-9.
//  Copyright (c) 2013年 com.ideal. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HorizFilter;

@protocol HorizFilterDataSource <NSObject>
@required
- (UIImage*) selectedItemImageForMenu:(HorizFilter*) horizMenu;
- (UIColor*) backgroundColorForMenu:(HorizFilter*) horizMenu;
- (int) numberOfItemsForMenu:(HorizFilter*) horizMenu;

- (NSString*) horizMenu:(HorizFilter*) horizMenu titleForItemAtIndex:(NSUInteger) index;
@end

@protocol HorizFilterDelegate <NSObject>
@required
- (void)horizMenu:(HorizFilter*) horizMenu itemSelectedAtIndex:(NSUInteger) index;
@end

@interface HorizFilter : UIScrollView {
    
    int _itemCount;
    UIImage *_selectedImage;
    NSMutableArray *_titles;
    id <HorizFilterDataSource> dataSource;
    id <HorizFilterDelegate> itemSelectedDelegate;
}

@property (nonatomic, retain) NSMutableArray *titles;
@property (nonatomic, assign) IBOutlet id <HorizFilterDelegate> itemSelectedDelegate;
@property (nonatomic, retain) IBOutlet id <HorizFilterDataSource> dataSource;
@property (nonatomic, retain) UIImage *selectedImage;
@property (nonatomic, assign) int itemCount;

-(void) reloadData;
-(void) setSelectedIndex:(int) index animated:(BOOL) animated;
@end
