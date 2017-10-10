//
//  SelfieCustomView.m
//  VanityDate
//
//  Created by iOSDevStar on 7/12/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import "SelfieCustomView.h"
#import "Global.h"

@implementation SelfieCustomView

- (void)awakeFromNib {
    // Initialization code
    self.m_userImageView.image = [UIImage imageNamed:DEFAULT_AVATAR_IMAGE];
    self.m_postImageView.image = [UIImage imageNamed:DEFAULT_SELFIE_IMAGE];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void) updateUI
{
    self.m_userImageView.layer.cornerRadius = self.m_userImageView.frame.size.height / 2.f;
    self.m_userImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.m_userImageView.layer.borderWidth = 2.f;
    self.m_userImageView.clipsToBounds = YES;

    self.m_postImageView.layer.cornerRadius = 5.f;
    self.m_postImageView.clipsToBounds = YES;

    if (self.m_bMode)
        [self.m_btnAction setTitle:@"Delete" forState:UIControlStateNormal];
    else
        [self.m_btnAction setTitle:@"Report" forState:UIControlStateNormal];
    
    self.m_lblTime.textColor = [UIColor whiteColor];
    [self.m_btnAction setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (IBAction)actionProcess:(id)sender {
    if (self.m_bMode)
        [self.delegate actionDelete:self index:self.m_nIdx];
    else
        [self.delegate actionReport:self index:self.m_nIdx];
}

@end
