//
//  ImageDetailView.h
//  IntelligentCommunity
//
//  Created by 高 欣 on 13-7-31.
//  Copyright (c) 2013年 com.ideal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IDGridView.h"
@interface ImageDetailView : UIView{
    IBOutlet IDGridView *_gridView;
    IBOutlet UIButton *_removeButton;
}
@property (assign,nonatomic) NSUInteger index;
@property (copy,nonatomic) NSArray *imageArray;
@end
