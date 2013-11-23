
#import <Foundation/Foundation.h>
#import "Client.h"
#import "GCDAsyncSocket.h"
#import "WebKit/WebView.h"
#import "WebKit/WebScriptObject.h"
#import "WebKit/WebFrame.h"

@interface JSAPI : NSObject {
    
    MenubarController *_menu;
    PanelController *_panel;
}

@property (nonatomic, strong) GCDAsyncSocket *socket;
@property (nonatomic, strong) Client *client;

@property (retain, nonatomic) MenubarController *menu;
@property (retain, nonatomic) PanelController *panel;

- (JSAPI*)init:(MenubarController*)menubar panel:(PanelController*)panel;

- (void)webView:(WebView *)sender didClearWindowObject:(WebScriptObject *)windowObject forFrame:(WebFrame *)frame;
- (void)webView:(WebView *)webView addMessageToConsole:(NSDictionary *)message;

- (void)message_received:(NSString*) text;
- (void)status_changed:(NSString*) new_status;
- (void)attempting_reconnect;
- (void)panel_shown;
- (void)panel_hidden;
- (void)disconnected;

- (void)setPanelShown:(BOOL)shown;
- (void)setMenuText:(NSString*)json;
- (BOOL)getPanelShown;
- (void)connect;
- (void)resize;
- (NSNumber*)getScreenWidth;
- (NSNumber*)getScreenHeight;
- (void)setMaxWidth:(NSNumber*)width;
- (void)quit;


+ (NSString *) webScriptNameForSelector:(SEL)sel;
+ (BOOL)isSelectorExcludedFromWebScript:(SEL)sel;

@end
