//
//  ForumCell.m
//  IntelligenceCommunity
//
//  Created by IdealRD on 13-7-19.
//  Copyright (c) 2013年 com.ideal. All rights reserved.
//

#import "ForumCell.h"
#import<QuartzCore/QuartzCore.h>

@interface ForumCell(){
    IBOutlet UIImageView *_imgIcon;
    IBOutlet UILabel *_lblUserName;
    IBOutlet UILabel *_lblPost;
    IBOutlet UILabel *_lblReplyAndView;
    IBOutlet UILabel *_lbllastReplier;
    IBOutlet UILabel *_lblDateTime;
}
@end

@implementation ForumCell

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

-(void) awakeFromNib
{
    // 头像添加边框
    CALayer *sublayer = [CALayer layer];
    sublayer.backgroundColor = [UIColor clearColor].CGColor;
    sublayer.frame = CGRectMake(-2, -2, 50, 50);
    sublayer.borderColor = [[UIColor lightGrayColor] CGColor];
    sublayer.borderWidth = 1.0f;
    [_imgIcon.layer addSublayer:sublayer];
}

#pragma mark -
#pragma mark Private methods
-(void) setForum:(Forum *)forum
{
    [_imgIcon setImageWithURL:[NSURL URLWithString:forum.submitUser.avatarUrl] placeholderImage:[UIImage imageNamed:DefaultAvatar]];
    _lblUserName.text = forum.submitUser.userName;
    _lblPost.text = forum.title;
    
    CGRect frame=_lblPost.frame;
    NSString* content = _lblPost.text;
    CGSize contentSize = [content sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(frame.size.width, MAXFLOAT)
                                 lineBreakMode:UILineBreakModeWordWrap];
    frame.size.height = contentSize.height+3;
    _lblPost.frame = frame;
    
    _lblReplyAndView.text = [NSString stringWithFormat:@"%d/%d", forum.replyCount, forum.viewCount];
    
    _lbllastReplier.text = forum.lastReplyUser.userName;
    
    // yyyy-MM-DD 12:00:00
    NSString *time = (forum.lastReplyTime.length > 0) ? forum.lastReplyTime : forum.createTime;
    _lblDateTime.text = (time.length > 16) ? [time substringToIndex:16] : time;
}


@end
