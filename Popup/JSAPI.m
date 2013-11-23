#import "JSAPI.h"
#import "PanelController.h"
#import "MenubarController.h"

@implementation JSAPI

@synthesize client = _client;
@synthesize socket = _socket;
@synthesize menu = _menu;
@synthesize panel = _panel;

- (JSAPI*)init:(MenubarController *)menubar panel:(PanelController *)panel {
    self = [super init];
    
    self.panel = panel;
    self.menu = menubar;
    panel.jsapi = self;
    [panel.web_view setFrameLoadDelegate:self];
    
    return self;
}

- (void)webView:(WebView *)sender didClearWindowObject:(WebScriptObject *)windowObject forFrame:(WebFrame *)frame {
    [windowObject setValue:self forKey:@"tracker_api"];
}

- (void)log:(NSString*)message {
    NSLog(@"jsapi log: %@", message);
    [[self.panel.web_view windowScriptObject] evaluateWebScript:[NSString stringWithFormat:@"console.log('%@')", message]];
}

- (void)panel_shown {
    [self log:@"running panel_shown"];
    [[self.panel.web_view windowScriptObject] evaluateWebScript:@"on_panel_shown()"];
}

- (void)panel_hidden {
    [self log:@"running panel_hidden"];
    [[self.panel.web_view windowScriptObject] evaluateWebScript:@"on_panel_hidden()"];
}


- (void)message_received:(NSString*) text {
    [self log:[NSString stringWithFormat:@"running message_received with %@", text]];
    [[self.panel.web_view windowScriptObject] callWebScriptMethod:@"on_message_received" withArguments:[NSArray arrayWithObject:text]];
}

- (void)status_changed:(NSString*) new_status {
    [self log:[NSString stringWithFormat:@"running status_changed with %@", new_status]];
    [[self.panel.web_view windowScriptObject] callWebScriptMethod:@"on_status_changed" withArguments:[NSArray arrayWithObject:new_status]];
}

- (void)attempting_reconnect {
    [self log:@"running attempting_reconnect"];
    [[self.panel.web_view windowScriptObject] evaluateWebScript:@"on_attempting_reconnect()"];
}

// ****************
// exposed api methods

- (void)setMenuText:(NSString*)json {
    NSError* error=nil;
    NSArray *items = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
    [self.menu setText:items];
}

- (void)setPanelShown:(BOOL)shown {
    self.panel.hasActivePanel = shown;
}

- (BOOL)getPanelShown {
    return self.panel.hasActivePanel;
}

- (void)connect {
    self.client = [[Client alloc] initWithJSAPI:self];
    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self.client delegateQueue:dispatch_get_main_queue()];
    NSError *err = nil;
    if (![self.socket connectToHost:@"127.0.0.1" onPort:18081 error:&err])
    {
        // If there was an error, it's likely something like "already connected" or "no delegate set"
        NSLog(@"I goofed: %@", err);
    }
    [self.client connectionBegan:self.socket];
}

- (void)sendline:(NSString*) text {
    [self.client sendline:text];
}

// ***************
// thingy that exposes api methods


+ (NSString *) webScriptNameForSelector:(SEL)sel
{
    NSString *name = nil;
    
    if (sel == @selector(connect)) name = @"connect";
    if (sel == @selector(setMenuText:)) name = @"setMenuText";
    if (sel == @selector(setPanelShown:)) name = @"setPanelShown";
    if (sel == @selector(getPanelShown)) name = @"getPanelShown";
    
    return name;
}

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)sel
{
    if (sel == @selector(connect) ||
        sel == @selector(setMenuText:) ||
        sel == @selector(setPanelShown:) ||
        sel == @selector(getPanelShown)) return NO;
    return YES;
}

@end
