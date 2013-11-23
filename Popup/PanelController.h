#import "BackgroundView.h"
#import "StatusItemView.h"

#define TD_DEBUG YES

@class PanelController;
@class TrackerInterface;
@class TextFieldDelegate;

@protocol PanelControllerDelegate <NSObject>

@optional

- (StatusItemView *)statusItemViewForPanelController:(PanelController *)controller;

@end

#pragma mark -

@interface PanelController : NSWindowController <NSWindowDelegate>
{
    BOOL _hasActivePanel;
    __unsafe_unretained BackgroundView *_backgroundView;
    __unsafe_unretained id<PanelControllerDelegate> _delegate;
    __unsafe_unretained NSTextField *_entry_box;
    __unsafe_unretained NSTextField *_contents;
    __unsafe_unretained TrackerInterface *_trackerInterface;
    __unsafe_unretained NSBox *_top_box;
}

@property (nonatomic, unsafe_unretained) IBOutlet BackgroundView *backgroundView;
@property (nonatomic, unsafe_unretained) IBOutlet NSTextField *contents;

@property (nonatomic, unsafe_unretained) IBOutlet NSTextField *entry_box;
@property (nonatomic, unsafe_unretained) IBOutlet NSBox *top_box;
@property (nonatomic, unsafe_unretained) TrackerInterface *trackerInterface;

@property (strong, nonatomic) TextFieldDelegate *entry_box_delegate;

@property (nonatomic) BOOL hasActivePanel;
@property (nonatomic, unsafe_unretained, readonly) id<PanelControllerDelegate> delegate;

- (id)initWithDelegate:(id<PanelControllerDelegate>)delegate;

- (void)openPanel;
- (void)closePanel;
- (NSRect)statusRectForWindow:(NSWindow *)window;

- (void)setContentsText:(NSArray*)line_array;
- (void)setInput:(NSString*) newValue;

- (void)panelSize;

- (IBAction)textFieldEnter:(NSTextField*)sender;
- (void)navigateHistory:(NSString*)direction;

- (void) hotkeyWithEvent:(NSEvent *)hkEvent;


@end
