#import "MenubarController.h"
#import "PanelController.h"
#import "GCDAsyncSocket.h"
#import "DDHotKeyCenter.h"
#import "JSAPI.h"


@class Client;

@interface ApplicationDelegate : NSObject <NSApplicationDelegate, PanelControllerDelegate>

@property (nonatomic, strong) MenubarController *menubarController;
@property (nonatomic, strong, readonly) PanelController *panelController;
@property (nonatomic, strong) Client *client;
@property (nonatomic, strong) GCDAsyncSocket *socket;
@property (nonatomic, strong) DDHotKeyCenter *hotkey;
@property (nonatomic, strong) JSAPI *jsapi;


- (IBAction)togglePanel:(id)sender;

@end
