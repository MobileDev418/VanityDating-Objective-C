//
//  MessageGateway.h
//  Whatsapp
//
//  Created by Rafael Castro on 7/4/15.
//  Copyright (c) 2015 HummingBird. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Message.h"

@protocol MessageGatewayDelegate;


//
// Class responsable to send message to server
// and notify status. It's also responsable to
// get messages in local storage.
//
@interface MessageGateway : NSObject
@property (assign, nonatomic) id<MessageGatewayDelegate> delegate;
-(void)sendMessage:(Message *)message;
@end


@protocol MessageGatewayDelegate <NSObject>
-(void)gatewayDidUpdateStatusForMessage:(Message *)message;
@end
