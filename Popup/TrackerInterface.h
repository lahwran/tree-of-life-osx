//
//  TrackerInterface.h
//  Popup
//
//  Created by lahwran on 8/25/12.
//

#import <Foundation/Foundation.h>

@class MenubarController;
@class PanelController;
@class GCDAsyncSocket;

@interface TrackerInterface : NSObject {
    NSArray *_prompt;
    NSArray *_messages;
    NSArray *_suggestions;
    NSArray *_context;
    
    NSString *_input;

    NSString *_status;
        
    GCDAsyncSocket *_socket;
    MenubarController *_menu;
    PanelController *_panel;
    
    float _delay;
}

@property (retain, nonatomic) NSArray *prompt;
@property (retain, nonatomic) NSArray *messages;
@property (retain, nonatomic) NSArray *context;
@property (retain, nonatomic) NSArray *suggestions;

@property (retain, nonatomic) NSString *input;

@property (retain, nonatomic) NSString *status;

@property (nonatomic) float delay;

@property (retain, nonatomic) GCDAsyncSocket *socket;
@property (retain, nonatomic) MenubarController *menu;
@property (retain, nonatomic) PanelController *panel;

- (TrackerInterface*)initWithMenuBar:(MenubarController*)menu withPanel:(PanelController*)panel;
- (void)updateMenuBar;
- (void)updatePanel;
- (void)connectionBegan:(GCDAsyncSocket*)socket;

- (void)attemptReconnect;
- (void)socketDidDisconnect:(GCDAsyncSocket*)socket withError:(NSError *)err;
- (void)socket:(GCDAsyncSocket*)socket didConnectToHost:(NSString *)host port:(uint16_t)port;

- (void)waitForNext;

- (void)doCommand;
- (void)navigateHistory:(NSString*)direction;
- (void)indicateDisplay:(BOOL)displayed;

@end
