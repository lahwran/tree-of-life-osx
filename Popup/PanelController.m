#import "PanelController.h"
#import "BackgroundView.h"
#import "StatusItemView.h"
#import "MenubarController.h"
#import "TrackerInterface.h"
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
@synthesize contents = _contents;
@synthesize entry_box = _entry_box;
@synthesize top_box = _top_box;
@synthesize trackerInterface = _trackerInterface;

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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSControlTextDidChangeNotification object:self.entry_box];
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
    [self panelSize];
    
    // Follow search string
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInput) name:NSControlTextDidChangeNotification object:self.entry_box];
    _entry_box_delegate = [[TextFieldDelegate alloc] initWithDelegate:self];
    self.entry_box.delegate = _entry_box_delegate;
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
        if (self.trackerInterface != nil) {
            [self.trackerInterface indicateDisplay:_hasActivePanel];
        }
        
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

- (void)updateInput
{
    NSString *input = [self.entry_box stringValue];
    self.trackerInterface.input = input;
    
}

- (void)setInput:(NSString*) newValue {
    if (![[self.entry_box stringValue] isEqualToString:newValue]) {
        [self.entry_box setStringValue:newValue];
    }
}

- (void)panelSize {
    for (int i=0; i<2; i++) {
        NSTextFieldCell *cell = [self.contents cell];
    
        NSSize textSize = [cell cellSizeForBounds:NSMakeRect(0, 0, FLT_MAX, FLT_MAX)];
        
        NSRect contentsRect = [self.contents bounds];
        NSRect contentsFrame = [self.contents frame];
        NSRect boxFrame = [self.top_box frame];
    
        int offset = boxFrame.size.height + 10;
        int result = offset + textSize.height + 5;
  
    
        contentsFrame.size.height = textSize.height;
        //contentsFrame.size.width = textSize.width;
        contentsFrame.origin.y = 20;
        contentsRect.size.height = textSize.height;
        //contentsRect.size.width = textSize.width;
    
  
        result = MAX(POPUP_HEIGHT, result);
    
        NSWindow *panel = [self window];
        NSRect statusRect = [self statusRectForWindow:panel];
        NSRect screenRect = [[[NSScreen screens] objectAtIndex:0] frame];

        NSRect panelRect = [panel frame];
        panelRect.size.width = MAX(PANEL_WIDTH, textSize.width + 50);
        panelRect.size.height = result;
        panelRect.origin.x = roundf(NSMaxX(statusRect) - NSWidth(panelRect));
        panelRect.origin.y = NSMaxY(statusRect) - NSHeight(panelRect);
    
        if (NSMaxX(panelRect) > (NSMaxX(screenRect))) {
            panelRect.origin.x -= NSMaxX(panelRect) - (NSMaxX(screenRect));
        }
    
        //[self.contents setFrame:contentsFrame];
        //[self.contents setBounds:contentsRect];
        [panel setFrame:panelRect display:YES];
        
        NSLog(@"contentsframe: %@", NSStringFromRect(contentsFrame));
        NSLog(@"contentsrect: %@", NSStringFromRect(contentsRect));
    
        [panel setAlphaValue:1];
    }
}

- (void)setContentsText:(NSArray *)line_array {
    NSString *text = [line_array componentsJoinedByString:@"\n"];
    [self.contents setStringValue:text];

    [self panelSize];
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
    
    [panel makeFirstResponder:self.entry_box];
}

- (void)closePanel
{
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:CLOSE_DURATION];
    [[[self window] animator] setAlphaValue:0];
    [NSAnimationContext endGrouping];
    
    dispatch_after(dispatch_walltime(NULL, NSEC_PER_SEC * CLOSE_DURATION * 2), dispatch_get_main_queue(), ^{
        
        [self.window orderOut:nil];
    });
}

- (IBAction)textFieldEnter:(NSTextField*)sender {
    [self.trackerInterface doCommand];
}

- (void)navigateHistory:(NSString *)direction {
    [self.trackerInterface navigateHistory:direction];
}


- (void) hotkeyWithEvent:(NSEvent *)hkEvent {
    NSLog(@"Hotkey event: %@", hkEvent);
    self.hasActivePanel = !self.hasActivePanel;
}

@end
