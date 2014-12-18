//
//  ContactsCell.m
//  IntelligentCommunity
//
//  Created by 高 欣 on 13-7-22.
//  Copyright (c) 2013年 com.ideal. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "ContactsCell.h"
#import "UIImageView+AFNetworking.h"

@interface ContactsCell(){
    IBOutlet UIImageView *_imgAvatar;
    IBOutlet UILabel *_lblUserName;
    IBOutlet UILabel *_lblMobile;
    IBOutlet UILabel *_lblEmail;
    IBOutlet UIView *_backView;
    IBOutlet UIView *_lineView;
}
@end
@implementation ContactsCell

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
    _backView.layer.borderWidth=1.0f;
    _backView.layer.borderColor=[UIColor lightGrayColor].CGColor;
    _lineView.layer.borderWidth=1.0f;
    _lineView.layer.borderColor=[UIColor lightGrayColor].CGColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) setUser:(User *)user
{
    _user=user;
    [_imgAvatar setImageWithURL:[NSURL URLWithString:user.avatarUrl] placeholderImage:[UIImage imageNamed:DefaultAvatar]];
    _lblUserName.text=user.userName;
    _lblMobile.text=user.mobile;
    _lblEmail.text=user.email;

}

@end
