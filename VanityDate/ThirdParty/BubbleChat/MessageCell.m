//
//  MessageCell.m
//  Whatsapp
//
//  Created by Rafael Castro on 6/16/15.
//  Copyright (c) 2015 HummingBird. All rights reserved.
//

#import "MessageCell.h"
#import "Global.h"

@interface MessageCell ()
@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) UIImageView *bubbleImage;
@property (strong, nonatomic) UIImageView *userImage;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UIImageView *statusIcon;
@end

@implementation MessageCell


-(CGFloat)height
{
    return _bubbleImage.frame.size.height + 14.f;
}
-(CGFloat)width
{
    return _bubbleImage.frame.size.width;
}
-(void)setMessage:(Message *)message
{
    _message = message;
    
    [self cleanView];
    
    [self addTextView];
    [self setTextView];
    
    [self addBubble];
    [self addUserImage];
    [self setBubble];
    
    [self addTimeLabel];
    [self setTimeLabel];
    
//    [self addStatusIcon];
//    [self setStatusIcon];
}

#pragma mark - 

-(void)awakeFromNib
{
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = [UIColor clearColor];
}
-(void)cleanView
{
    for (UIView *view in self.contentView.subviews)
        [view removeFromSuperview];
    
    _textView = nil;
    _timeLabel = nil;
    _bubbleImage = nil;
    _userImage = nil;
}

#pragma mark - TextView

-(void)addTextView
{
    CGFloat max_witdh = 0.7*[UIScreen mainScreen].bounds.size.width;
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, max_witdh, MAXFLOAT)];
    _textView.font = [UIFont fontWithName:MAIN_FONT_NAME size:14.0];
    _textView.backgroundColor = [UIColor clearColor];
    _textView.userInteractionEnabled = NO;
    [self.contentView addSubview:_textView];
}
-(void)setTextView
{
    _textView.text = _message.text;
    [_textView sizeToFit];
}

#pragma mark - BubbleImage

-(void)addBubble
{
    _bubbleImage = [[UIImageView alloc] init];
    _bubbleImage.userInteractionEnabled = YES;
    [self.contentView insertSubview:_bubbleImage belowSubview:_textView];
}

-(void)addUserImage
{
    _userImage = [[UIImageView alloc] init];
    _userImage.userInteractionEnabled = YES;
    [self.contentView insertSubview:_userImage belowSubview:_textView];
}

- (void)setBubble
{
    //Estimation of TextView Size
    CGFloat textView_x;
    CGFloat textView_y;
    CGFloat userImageView_x;
    CGFloat userImageView_y;
    CGFloat textView_width = _textView.frame.size.width;
    if (textView_width < 60.f)
        textView_width = 60.f;
    
    CGFloat textView_height = _textView.frame.size.height;
    CGFloat textView_marginLeft;
    CGFloat textView_marginRight;
    CGFloat textView_marginBottom = 5;
    
    CGFloat imageView_size = 44.f;
    //Bubble positions
    CGFloat bubble_x;
    CGFloat bubble_y;
    CGFloat bubble_width;
    CGFloat bubble_height;
    
    UIViewAutoresizing autoresizing;
    
    if (self.message.sender == MessageSenderMyself)
    {
        textView_marginLeft = 15;
        textView_marginRight = 15;
        bubble_x = [UIScreen mainScreen].bounds.size.width - textView_width - textView_marginLeft - textView_marginRight - 20 - imageView_size;
        userImageView_x = [UIScreen mainScreen].bounds.size.width - 20 - imageView_size;
        bubble_y = 1;
        if (textView_height > imageView_size)
            userImageView_y = textView_height - imageView_size;
        else
            userImageView_y = bubble_y;
        
        self.bubbleImage.image = [[UIImage imageNamed:@"bubble"]
                                  stretchableImageWithLeftCapWidth:21 topCapHeight:14];
        
        textView_x = bubble_x + textView_marginLeft;
        textView_y = 0;
        
        bubble_width = textView_width + 20;
        self.userImage.image = [UIImage imageNamed:DEFAULT_AVATAR_IMAGE];
        autoresizing = UIViewAutoresizingFlexibleLeftMargin;

        self.textView.textColor = [UIColor darkGrayColor];
    }
    else
    {
        bubble_x = 20 + imageView_size;
        userImageView_x = 20;

        bubble_y = 1;
        if (textView_height > imageView_size)
            userImageView_y = textView_height - imageView_size;
        else
            userImageView_y = bubble_y;

        self.bubbleImage.image = [[UIImage imageNamed:@"bubbleSomeone.png"]
                                  stretchableImageWithLeftCapWidth:21 topCapHeight:14];
        
        textView_marginLeft = 15;
        textView_marginRight = 15;
        textView_x = bubble_x + textView_marginLeft;
        textView_y = 0;
    
        self.userImage.image = [UIImage imageNamed:DEFAULT_AVATAR_IMAGE];
        autoresizing = UIViewAutoresizingFlexibleRightMargin;
        
        self.textView.textColor = [UIColor whiteColor];
    }
    
    [[Utils sharedObject] loadImageFromServerAndLocalWithoutRound:[NSString stringWithFormat:@"%@%@", RESOURCE_URL, self.message.imagepath] imageView:self.userImage];
    
    bubble_width = textView_width + textView_marginLeft + textView_marginRight;
    bubble_height = textView_height + textView_marginBottom;
    
    //Set frame
    self.textView.frame = CGRectMake(textView_x, textView_y, textView_width, textView_height);
    self.bubbleImage.frame = CGRectMake(bubble_x, bubble_y, bubble_width, bubble_height);
    self.userImage.frame = CGRectMake(userImageView_x, userImageView_y, imageView_size, imageView_size);
    
    self.bubbleImage.alpha = 0.6f;
    //Set textView
//    self.textView.autoresizingMask = autoresizing;
//    self.bubbleImage.autoresizingMask = autoresizing;
//    self.userImage.autoresizingMask = autoresizing;
    
    [self addShadowToBubble];
}
-(void)addShadowToBubble
{
    UIImageView *imageView = self.bubbleImage;
    //shadow part
    imageView.layer.shadowColor = [UIColor blackColor].CGColor;
    imageView.layer.shadowOffset = CGSizeMake(0, 1);
    imageView.layer.shadowOpacity = .2;
    imageView.layer.shadowRadius = .5;
    
    //Add performace to shadow creation
    //If you remove this code, scroll in tableView will become slow
    imageView.layer.shouldRasterize = YES;
    imageView.layer.rasterizationScale = UIScreen.mainScreen.scale;
    
    UIImageView *userImageView = self.userImage;
    userImageView.layer.cornerRadius = userImageView.frame.size.height / 2;
    userImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    userImageView.layer.borderWidth = 2.f;
    userImageView.clipsToBounds = YES;
}

#pragma mark - TimeLabel

-(void)addTimeLabel
{
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 70, 20)];
    _timeLabel.textColor = [UIColor lightGrayColor];
    _timeLabel.font = [UIFont fontWithName:MAIN_FONT_NAME size:12.0];
    _timeLabel.userInteractionEnabled = NO;
    [self.contentView addSubview:_timeLabel];
}
-(void)setTimeLabel
{
    //Set Text to Label
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.timeStyle = NSDateFormatterShortStyle;
    df.dateStyle = NSDateFormatterNoStyle;
    df.doesRelativeDateFormatting = YES;
    self.timeLabel.text = [df stringFromDate:self.message.sent];
    [self.timeLabel sizeToFit];
    
    //Set position
    CGFloat time_x = _bubbleImage.frame.origin.x + _bubbleImage.frame.size.width - _timeLabel.frame.size.width;
    CGFloat time_y = self.height - _timeLabel.frame.size.height - 14.f;
    UIViewAutoresizing autoresizing;

    if (self.message.sender == MessageSenderMyself)
    {
        time_x = time_x - 20;
        autoresizing = UIViewAutoresizingFlexibleLeftMargin;
        
        self.timeLabel.textColor = [UIColor darkGrayColor];
    }
    else
    {
        time_x = time_x - 15;
        autoresizing = UIViewAutoresizingFlexibleRightMargin;

        self.timeLabel.textColor = [UIColor whiteColor];
    }
    
    self.timeLabel.frame = CGRectMake(time_x,
                                      time_y,
                                      self.timeLabel.frame.size.width,
                                      self.timeLabel.frame.size.height);
    
//    self.timeLabel.autoresizingMask = autoresizing;
    
    [self addSingleLineCase];
}
-(void)addSingleLineCase
{
    CGFloat delta_x = _timeLabel.frame.size.width + 2;
    CGRect time_frame = self.timeLabel.frame;
    
    CGFloat bubble_width = _bubbleImage.frame.size.width;
    CGFloat view_width = [UIScreen mainScreen].bounds.size.width;//self.contentView.frame.size.width;
    
    //Single Line Case
    if (self.height <= 45 && bubble_width + delta_x <= 0.8*view_width)
    {
        if (self.message.sender == MessageSenderMyself)
        {
            delta_x += 2;
            [self view:_textView shiftOriginX:-delta_x];
            [self increaseBubble:delta_x shiftOriginX:-delta_x];
        }
        else
        {
            time_frame.origin.x += delta_x;
            [self increaseBubble:delta_x shiftOriginX:0];
        }
        
        self.timeLabel.frame = time_frame;
    }
}

#pragma mark - StatusIcon

-(void)addStatusIcon
{
    CGRect time_frame = _timeLabel.frame;
    CGRect status_frame = CGRectMake(0, 0, 15, 10);
    status_frame.origin.x = time_frame.origin.x + time_frame.size.width + 5;
    status_frame.origin.y = time_frame.origin.y;
    _statusIcon = [[UIImageView alloc] initWithFrame:status_frame];
    _statusIcon.contentMode = UIViewContentModeLeft;
    _statusIcon.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [self.contentView addSubview:_statusIcon];
}
-(void)setStatusIcon
{
    if (self.message.status == MessageStatusSent)
        _statusIcon.image = [UIImage imageNamed:@"status_sent"];
    else if (self.message.status == MessageStatusNotified)
        _statusIcon.image = [UIImage imageNamed:@"status_notified"];
    else if (self.message.status == MessageStatusRead)
        _statusIcon.image = [UIImage imageNamed:@"status_read"];
    
    _statusIcon.hidden = _message.sender == MessageSenderSomeone;
    
    //Animate Transition
    _statusIcon.alpha = 0;
    [UIView animateWithDuration:.5 animations:^{
        _statusIcon.alpha = 1;
    }];
}

#pragma mark - Helpers

-(void)increaseBubble:(CGFloat)deltaWidth shiftOriginX:(CGFloat)deltaX
{
    CGRect frame = _bubbleImage.frame;
    frame.size.width += deltaWidth;
    frame.origin.x += deltaX;
    _bubbleImage.frame = frame;
}
-(void)view:(UIView *)view shiftOriginX:(CGFloat)deltaX
{
    CGRect frame = view.frame;
    frame.origin.x += deltaX;
    view.frame = frame;
}
-(CGSize)measureSizeOfUITextView
{
    CGFloat max_width = 0.7*[UIScreen mainScreen].bounds.size.width;
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, max_width, MAXFLOAT)];
    textView.font = _textView.font;
    textView.text = _textView.text;
    [textView sizeToFit];
    return textView.frame.size;
}


@end
