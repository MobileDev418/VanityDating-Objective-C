//
//  MessageGateway.m
//  Whatsapp
//
//  Created by Rafael Castro on 7/4/15.
//  Copyright (c) 2015 HummingBird. All rights reserved.
//

#import "MessageGateway.h"

@interface MessageGateway()
@property (strong, nonatomic) NSMutableArray *messages_to_send;
@end


@implementation MessageGateway

-(id)init
{
    self = [super init];
    if (self)
    {
        self.messages_to_send = [[NSMutableArray alloc] init];
    }
    return self;
}
-(void)sendMessage:(Message *)message
{
    [self performSelector:@selector(updateMessageStatus:) withObject:message afterDelay:0.1f];
}
-(void)updateMessageStatus:(Message *)message
{
    if (message.status == MessageStatusSending)
        message.status = MessageStatusSent;
    else if (message.status == MessageStatusSent)
        message.status = MessageStatusNotified;
    else if (message.status == MessageStatusNotified)
        message.status = MessageStatusRead;
    
    [self.delegate gatewayDidUpdateStatusForMessage:message];
}
@end
