#import "BackgroundView.h"
#import "StatusItemView.h"
#import "WebKit/WebView.h"
#import "WebKit/WebFrame.h"
#import "WebKit/WebScriptObject.h"

#define TD_DEBUG YES

@class PanelController;
@class Client;
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
    __unsafe_unretained Client *_trackerInterface;
    __unsafe_unretained NSBox *_top_box;
    __unsafe_unretained WebView *_web_view;
}

@property (nonatomic, unsafe_unretained) IBOutlet BackgroundView *backgroundView;

@property (nonatomic, unsafe_unretained) IBOutlet WebView *web_view;

@property (strong, nonatomic) TextFieldDelegate *entry_box_delegate;

@property (nonatomic) BOOL hasActivePanel;
@property (nonatomic) id jsapi;
@property (nonatomic, unsafe_unretained, readonly) id<PanelControllerDelegate> delegate;

- (id)initWithDelegate:(id<PanelControllerDelegate>)delegate;

- (void)openPanel;
- (void)closePanel;
- (NSRect)statusRectForWindow:(NSWindow *)window;

- (void)panelSize;

- (void) hotkeyWithEvent:(NSEvent *)hkEvent;


@end
