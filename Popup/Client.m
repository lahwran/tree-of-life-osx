//
//  TrackerInterface.m
//  Popup
//
//  Created by lahwran on 8/25/12.
//

#import "Client.h"
#import "MenubarController.h"
#import "PanelController.h"
#import "GCDAsyncSocket.h"

#define ENCODING NSUTF8StringEncoding

@implementation Client

@synthesize status = _status;
@synthesize jsapi = _jsapi;

@synthesize socket = _socket;

@synthesize delay = _delay;

- (Client*)initWithJSAPI:(id)jsapi {
    self = [super init];
    
    self.jsapi = jsapi;
    self.status = @"not connected";
    self.delay = 0.1;
        
    return self;
}

- (void)connectionBegan:(GCDAsyncSocket*)socket {
    self.socket = socket;
    self.status = @"connecting";
    [self waitForNext];
}

- (void)socket:(GCDAsyncSocket*)socket didConnectToHost:(NSString *)host port:(uint16_t)port {
    self.status = @"connected";
    self.delay = 0.1;
}

- (void)attemptReconnect {
    [self.jsapi performSelector:@selector(attempting_reconnect)];
    NSError *err = nil;
    if (![self.socket connectToHost:@"127.0.0.1" onPort:18081 error:&err])
    {
        // If there was an error, it's likely something like "already connected" or "no delegate set"
        NSLog(@"I goofed: %@", err);
        self.status = @"error connecting";
    } else {
        [self connectionBegan:self.socket];
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket*)socket withError:(NSError *)err{
    NSLog(@"connection error: %@", err);
    [self.jsapi performSelector:@selector(disconnected)];
    self.status = [NSString stringWithFormat:@"disconnected (retry in %.01f)", self.delay];
    [self performSelector:@selector(attemptReconnect) withObject:nil afterDelay:self.delay];
    if (self.delay < 5.0) {
        self.delay = self.delay + 0.1;
    }
}

// ------------------------

- (void)waitForNext {
    [self.socket readDataToData:[@"\n" dataUsingEncoding:ENCODING] withTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket*)socket didReadData:(NSData*)data withTag:(long)tag {
    NSString *text = [[NSString alloc] initWithData:data encoding:ENCODING];
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n"]];
    if (TD_DEBUG) {
        NSLog(@"received text: %@", text);
    }
    [self.jsapi performSelector:@selector(message_received:) withObject:text];
    [self waitForNext];
}

// ------------------------

- (void)setStatus:(NSString *)new_status {
    if (TD_DEBUG) {
        NSLog(@"setting status: %@", new_status);
    }
    _status = new_status;
    [self.jsapi performSelector:@selector(status_changed:) withObject:new_status];
}

- (void)sendline:(NSString *)data {
    NSMutableData *messagedata = [NSMutableData dataWithData:[data dataUsingEncoding:ENCODING]];
    [messagedata appendData:[@"\n" dataUsingEncoding:ENCODING]];
    
    [self.socket writeData:messagedata withTimeout:-1 tag:0];
}

- (void)reconnect {
    if ([self.socket isConnected]) {
        [self.socket disconnect];
    }
}

@end
