#import <Foundation/Foundation.h>

@class MenubarController;
@class PanelController;
@class GCDAsyncSocket;

@interface Client : NSObject {

    NSString *_status;
        
    GCDAsyncSocket *_socket;
    
    float _delay;
    id _jsapi;
}

@property (retain, nonatomic) NSString *status;
@property (nonatomic) id jsapi;

@property (nonatomic) float delay;

@property (retain, nonatomic) GCDAsyncSocket *socket;

- (Client*)initWithJSAPI:(id)jsapi;
- (void)connectionBegan:(GCDAsyncSocket*)socket;

- (void)attemptReconnect;
- (void)socketDidDisconnect:(GCDAsyncSocket*)socket withError:(NSError *)err;
- (void)socket:(GCDAsyncSocket*)socket didConnectToHost:(NSString *)host port:(uint16_t)port;

- (void)waitForNext;

- (void)sendline:(NSString*)data;
- (void)reconnect;

@end
