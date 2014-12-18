//
//  FilterMenuCell.m
//  IntelligentCommunity
//
//  Created by 高 欣 on 13-4-9.
//  Copyright (c) 2013年 com.ideal. All rights reserved.
//

#import "FilterMenuCell.h"

@implementation FilterMenuCell

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
    [self setNeedsDisplay];
    // Configure the view for the selected state
}
- (void)drawRect:(CGRect)rect {
    // Drawing code
    if(self.selected){
        UIImage *imgSelectedMenu = [UIImage imageNamed:@"DropdownMenu_Selected"];
        imgSelectedMenu = [imgSelectedMenu resizableImageWithCapInsets:UIEdgeInsetsMake(0,20, 0, 0)];
        [imgSelectedMenu drawInRect:CGRectMake(0, 0,self.frame.size.width , self.frame.size.height)];
    }else{
        [super drawRect:rect];
    } 
}
@end
