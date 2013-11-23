#import "MenubarController.h"
#import "PanelController.h"
#import "GCDAsyncSocket.h"
#import "DDHotKeyCenter.h"


@class TrackerInterface;

@interface ApplicationDelegate : NSObject <NSApplicationDelegate, PanelControllerDelegate>

@property (nonatomic, strong) MenubarController *menubarController;
@property (nonatomic, strong, readonly) PanelController *panelController;
@property (nonatomic, strong) TrackerInterface *client;
@property (nonatomic, strong) GCDAsyncSocket *socket;
@property (nonatomic, strong) DDHotKeyCenter *hotkey;


- (IBAction)togglePanel:(id)sender;

@end
