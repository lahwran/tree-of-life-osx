#import "StatusItemView.h"

// magic numbers from http://undefinedvalue.com/2009/07/07/adding-custom-view-nsstatusitem
#define StatusItemViewPaddingWidth  6
#define StatusItemViewPaddingHeight 3

#define MAIN_ALPHA 1.0
#define SECONDARY_ALPHA 0.3

@implementation StatusItemView

@synthesize statusItem = _statusItem;
@synthesize parentText= _parentText;
@synthesize mainText = _mainText;
@synthesize isHighlighted = _isHighlighted;
@synthesize action = _action;
@synthesize target = _target;

#pragma mark -

- (id)initWithFrame:(NSRect)frame{
    self = [super initWithFrame:frame];

    if (self != nil) {
        _statusItem = nil;
        _mainText = @"";
        _parentText = @"";
        _isHighlighted = NO;
    }
    return self;
}


#pragma mark -

- (NSColor *)titleForegroundColorWithHighlight:(BOOL)highlight {
    if (highlight) {
        return [NSColor whiteColor];
    }
    else {
        return [NSColor blackColor];
    }    
}


- (NSDictionary *)titleAttributesWithAlpha:(CGFloat)alpha withHighlight:(BOOL)highlight {
    // Use default menu bar font size
    NSFont *font = [NSFont menuBarFontOfSize:0];
    
    NSColor *foregroundColor = [self titleForegroundColorWithHighlight:highlight];
    NSColor *alphaColor = [foregroundColor colorWithAlphaComponent:alpha];
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            font,            NSFontAttributeName,
            alphaColor, NSForegroundColorAttributeName,
            nil];
}

- (NSRect)titleBoundingRect:(NSString*)some_parent_text mainText:(NSString*)some_main_text {
    NSRect parentRect = [some_parent_text boundingRectWithSize:NSMakeSize(1e100, 1e100) options:0
                                              attributes:[self titleAttributesWithAlpha:SECONDARY_ALPHA withHighlight:NO]];
    NSRect mainRect = [some_main_text boundingRectWithSize:NSMakeSize(1e100, 1e100) options:0
                                              attributes:[self titleAttributesWithAlpha:MAIN_ALPHA withHighlight:NO]];
    NSRect result = NSMakeRect(parentRect.origin.x, parentRect.origin.y,
                               parentRect.size.width + mainRect.size.width,
                               parentRect.size.height + mainRect.size.height);
    return result;
}

- (int) getTextWidth:(NSString *)some_parent_text mainText:(NSString *)some_main_text {
    return [self titleBoundingRect:some_parent_text mainText:some_main_text].size.width;
}

- (NSRect)titleBoundingRect {
    return [self titleBoundingRect:parentText mainText:mainText];
}

- (void)drawRect:(NSRect)dirtyRect
{
    
    NSPoint parentOrigin = NSMakePoint(StatusItemViewPaddingWidth,
                                       StatusItemViewPaddingHeight);
    NSDictionary *parentAttributes = [self titleAttributesWithAlpha:SECONDARY_ALPHA withHighlight:NO];
    NSSize parentSize = [parentText sizeWithAttributes:parentAttributes];
    
    
    NSPoint mainOrigin = NSMakePoint(StatusItemViewPaddingWidth + parentSize.width, StatusItemViewPaddingHeight);
    NSDictionary *mainAttributes = [self titleAttributesWithAlpha:MAIN_ALPHA withHighlight:_isHighlighted];
    NSRect bounds = [self bounds];
    CGFloat xoffset = mainOrigin.x - StatusItemViewPaddingWidth;
    NSRect highlightRect = NSMakeRect(bounds.origin.x + xoffset, bounds.origin.y,
                                      bounds.size.width - xoffset, bounds.size.height);

    [self.statusItem drawStatusBarBackgroundInRect:highlightRect withHighlight:self.isHighlighted];
    
    [parentText drawAtPoint:parentOrigin withAttributes:parentAttributes];
    [mainText drawAtPoint:mainOrigin withAttributes:mainAttributes];
}

- (void) updateDisplay {
    NSRect titleBounds = [self titleBoundingRect];
    int newWidth = titleBounds.size.width + (StatusItemViewPaddingWidth * 2);
    [_statusItem setLength:newWidth];
    [self setBounds:NSMakeRect(0, 0, newWidth, [[NSStatusBar systemStatusBar] thickness])];
    [self setNeedsDisplay:YES];
}

- (void)setMainText:(NSString *)newMainText {
    if (![mainText isEqual:newMainText]) {
        mainText = newMainText;
        [self updateDisplay];
    }
}

- (NSString *)mainText {
    return mainText;
}

- (void)setParentText:(NSString *)newParentText {
    if (![parentText isEqual:newParentText]) {
        parentText = newParentText;
        [self updateDisplay];
    }
}

- (NSString *)parentText {
    return parentText;
}

#pragma mark -
#pragma mark Mouse tracking

- (void)mouseDown:(NSEvent *)theEvent
{
    [NSApp sendAction:self.action to:self.target from:self];
}

- (void)rightMouseDown:(NSEvent *)event {
    // Treat right-click just like left-click
    [self mouseDown:event];
}

#pragma mark -
#pragma mark Accessors

- (void)setHighlighted:(BOOL)newFlag
{
    if (_isHighlighted == newFlag) return;
    _isHighlighted = newFlag;
    [self setNeedsDisplay:YES];
}

#pragma mark -


#pragma mark -

- (NSRect)globalRect
{
    NSDictionary *parentAttributes = [self titleAttributesWithAlpha:SECONDARY_ALPHA withHighlight:NO];
    NSSize parentSize = [parentText sizeWithAttributes:parentAttributes];
    CGFloat xoffset = parentSize.width;

    NSRect bounds = [self bounds];
    NSRect highlightRect = NSMakeRect(bounds.origin.x + xoffset, bounds.origin.y,
                                      bounds.size.width - xoffset, bounds.size.height);
    highlightRect.origin = [self.window convertBaseToScreen:highlightRect.origin];
    return highlightRect;
}

@end
