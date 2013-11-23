#import "PanelController.h"
#import "BackgroundView.h"
#import "StatusItemView.h"
#import "MenubarController.h"
#import "Client.h"
#import "TextFieldDelegate.h"

#define OPEN_DURATION 1
#define CLOSE_DURATION 0

#define SEARCH_INSET 17

#define POPUP_HEIGHT 50
#define PANEL_WIDTH 500
#define MENU_ANIMATION_DURATION 0

#pragma mark -

@implementation PanelController

@synthesize backgroundView = _backgroundView;
@synthesize delegate = _delegate;

@synthesize entry_box_delegate = _entry_box_delegate;


#pragma mark -

- (id)initWithDelegate:(id<PanelControllerDelegate>)delegate
{
    self = [super initWithWindowNibName:@"Panel"];
    if (self != nil)
    {
        _delegate = delegate;

    }
    return self;
}

#pragma mark -

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // Make a fully skinned panel
    NSPanel *panel = (id)[self window];
    [panel setAcceptsMouseMovedEvents:YES];
    [panel setLevel:NSPopUpMenuWindowLevel];
    [panel setOpaque:NO];
    [panel setBackgroundColor:[NSColor clearColor]];
    
    // Resize panel
    
    [self.delegate performSelector:@selector(panelready)];
    [self.web_view setMainFrameURL:@"http://127.0.0.1:18082/ui.html"];
    [self panelSize];
}

#pragma mark - Public accessors

- (BOOL)hasActivePanel
{
    return _hasActivePanel;
}

- (void)setHasActivePanel:(BOOL)flag
{
    if (_hasActivePanel != flag)
    {
        _hasActivePanel = flag;
        
        
        if (_hasActivePanel)
        {
            [self openPanel];
        }
        else
        {
            [self closePanel];
        }
    }
}

#pragma mark - NSWindowDelegate

- (void)windowWillClose:(NSNotification *)notification
{
    self.hasActivePanel = NO;
}

- (void)windowDidResignKey:(NSNotification *)notification;
{
    if ([[self window] isVisible])
    {
        self.hasActivePanel = NO;
    }
}

#pragma mark - Keyboard

- (void)cancelOperation:(id)sender
{
    self.hasActivePanel = NO;
}

- (void)panelSize {
    NSNumber *width = [[self.web_view windowScriptObject] evaluateWebScript:@"on_calculate_width()"];
    NSNumber *height = [[self.web_view windowScriptObject] evaluateWebScript:@"on_calculate_height()"];
    for (int i=0; i<2; i++) {
        NSWindow *panel = [self window];
        NSRect statusRect = [self statusRectForWindow:panel];
        NSRect screenRect = [[[NSScreen screens] objectAtIndex:0] frame];

        NSRect panelRect = [panel frame];
        panelRect.size.width = [width integerValue];
        panelRect.size.height = [height integerValue] + 5;
        panelRect.origin.x = roundf(NSMaxX(statusRect) - NSWidth(panelRect));
        panelRect.origin.y = NSMaxY(statusRect) - NSHeight(panelRect);
    
        if (NSMaxX(panelRect) > (NSMaxX(screenRect))) {
            panelRect.origin.x -= NSMaxX(panelRect) - (NSMaxX(screenRect));
        }
    
        //[self.contents setFrame:contentsFrame];
        //[self.contents setBounds:contentsRect];
        [panel setFrame:panelRect display:YES];
    
        [panel setAlphaValue:1];
    }
}

#pragma mark - Public methods

- (NSRect)statusRectForWindow:(NSWindow *)window
{
    NSRect statusRect = NSZeroRect;
    
    StatusItemView *statusItemView = [self.delegate statusItemViewForPanelController:self];

    statusRect = statusItemView.globalRect;
    statusRect.origin.y = NSMinY(statusRect) - NSHeight(statusRect);
    
    return statusRect;
}

- (void)openPanel
{
    NSWindow *panel = [self window];
    
        
    NSRect statusRect = [self statusRectForWindow:panel];

    [NSApp activateIgnoringOtherApps:NO];
    [panel setAlphaValue:0];
    [panel setFrame:statusRect display:YES];
    [panel makeKeyAndOrderFront:nil];
    
    [self panelSize];
    
    [panel makeFirstResponder:self.web_view];
    [self.jsapi performSelector:@selector(panel_shown)];
    [panel makeFirstResponder:self.web_view];

}

- (void)closePanel
{
    [self.jsapi performSelector:@selector(panel_hidden)];
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:CLOSE_DURATION];
    [[[self window] animator] setAlphaValue:0];
    [NSAnimationContext endGrouping];
    
    dispatch_after(dispatch_walltime(NULL, NSEC_PER_SEC * CLOSE_DURATION * 2), dispatch_get_main_queue(), ^{
        
        [self.window orderOut:nil];
    });
}


- (void) hotkeyWithEvent:(NSEvent *)hkEvent {
    NSLog(@"Hotkey event: %@", hkEvent);
    self.hasActivePanel = !self.hasActivePanel;
}

@end
