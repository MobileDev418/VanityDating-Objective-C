//
//  SelfieCustomView.h
//  VanityDate
//
//  Created by iOSDevStar on 7/12/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelfieCustomViewDelegate;

@interface SelfieCustomView : UIView

@property (nonatomic,strong) id<SelfieCustomViewDelegate> delegate;

@property (nonatomic, assign) int m_nIdx;

@property (nonatomic, assign) bool m_bMode;
@property (weak, nonatomic) IBOutlet UIImageView *m_postImageView;

@property (weak, nonatomic) IBOutlet UIImageView *m_userImageView;
@property (weak, nonatomic) IBOutlet UILabel *m_lblTime;

@property (weak, nonatomic) IBOutlet UIButton *m_btnAction;
- (IBAction)actionProcess:(id)sender;

- (void) updateUI;

@end

@protocol SelfieCustomViewDelegate <NSObject>
- (void) actionDelete:(SelfieCustomView *) selfieView index:(int) nSelectedIdx;
- (void) actionReport:(SelfieCustomView *) selfieView index:(int) nSelectedIdx;
@end
