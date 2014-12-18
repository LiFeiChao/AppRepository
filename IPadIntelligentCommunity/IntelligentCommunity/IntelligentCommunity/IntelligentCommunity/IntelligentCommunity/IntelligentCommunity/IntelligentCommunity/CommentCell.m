//
//  CommentCell.m
//  IntelligenceCommunity
//
//  Created by 高 欣 on 12-11-8.
//  Copyright (c) 2012年 Ideal. All rights reserved.
//

#import "CommentCell.h"
#import "UIImageView+AFNetworking.h"
#import <QuartzCore/QuartzCore.h>


@interface CommentCell(){
    IBOutlet UILabel *_lblUserName;
    IBOutlet UILabel *_lblContent;
    IBOutlet UILabel *_lblDateTime;
    IBOutlet UIImageView *_imgIcon;
}
@end
@implementation CommentCell 
    
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) awakeFromNib
{
    // 头像添加边框
    CALayer *sublayer = [CALayer layer];
    sublayer.backgroundColor = [UIColor clearColor].CGColor;
    sublayer.frame = CGRectMake(-3, -3,56,56);
    sublayer.borderColor = [[UIColor lightGrayColor] CGColor];
    sublayer.borderWidth = 1.0f;
    [_imgIcon.layer addSublayer:sublayer];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark -
#pragma mark Private methods

-(void) setComment:(Comment *)comment
{
    [_imgIcon setImageWithURL:[NSURL URLWithString:comment.submitUser.avatarUrl] placeholderImage:[UIImage imageNamed:DefaultAvatar]];
    _lblUserName.text=comment.submitUser.userName;
    
    _lblContent.text=comment.content;
    [_lblContent sizeToFit];
 // [self setNeedsLayout];
    
    _lblDateTime.text=comment.createTime;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    CGRect frameDateTime=_lblDateTime.frame;
    
    frameDateTime.origin.y=_lblContent.frame.origin.y+_lblContent.frame.size.height+8;
    if (frameDateTime.origin.y > _lblDateTime.frame.origin.y)
    {
        _lblDateTime.frame = frameDateTime;
    }
}
@end
