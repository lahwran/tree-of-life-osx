#import "MenubarController.h"
#import "StatusItemView.h"

@implementation MenubarController

@synthesize max_width = _max_width;
@synthesize statusItemView = _statusItemView;
@synthesize text = _text;
@synthesize alerts = _alerts;

#pragma mark -

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        // Install status item into the menu bar
        NSStatusItem *statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
        _statusItemView = [[StatusItemView alloc] init];
        statusItem.view = _statusItemView;
        [_statusItemView setStatusItem:statusItem];
        _statusItemView.action = @selector(togglePanel:);
        
        self.text = [NSArray arrayWithObjects: @"todo tracker", nil];
        [statusItem setHighlightMode:YES];

        [statusItem setEnabled:YES];
        self.max_width = 500;

    }
    return self;
}

- (void)dealloc
{
    [[NSStatusBar systemStatusBar] removeStatusItem:self.statusItem];
}

#pragma mark -
#pragma mark Public accessors

- (NSStatusItem *)statusItem
{
    return self.statusItemView.statusItem;
}

- (void)setText:(NSArray *)new_text {
    NSString *parenttext = nil;
    NSString *maintext = @"todo tracker: no text";
    int element_offset = 0;
    int character_offset = 0;
    int actual_width = 0;
    
    do {
        parenttext = [NSString string];
        
        long max_index = [new_text count] - 1;
        for (long index=max_index; index >= element_offset; index-=1) {
            NSString* string = [new_text objectAtIndex:index];
            if (index == element_offset && character_offset) {
                if (character_offset >= [string length]) {
                    character_offset = 0;
                    element_offset += 1;
                }
                NSRange cut_range = NSMakeRange(0, [string length]-character_offset);
                cut_range = [string rangeOfComposedCharacterSequencesForRange:cut_range];
                string = [NSString stringWithFormat:@"%@...", [string substringWithRange:cut_range]];
            }
            
            if (index == max_index) {
                maintext = string;
            } else {
                parenttext = [NSString stringWithFormat:@"%@  ■  %@",
                              string,
                              parenttext];
            }
        }
        
        character_offset += 1;
        if (element_offset >= [new_text count]) {
            parenttext = @"error: ";
            maintext = @"text too long";
            
            NSLog(@"text too long");
            break;
        }
        actual_width = [_statusItemView getTextWidth:parenttext mainText:maintext];
    } while (actual_width > self.max_width);

    [_statusItemView setMainText:maintext];
    [_statusItemView setParentText:parenttext];
    text = new_text;
}

- (NSArray *)text {
    return text;
}

#pragma mark -

- (BOOL)hasActiveIcon
{
    return self.statusItemView.isHighlighted;
}

- (void)setHasActiveIcon:(BOOL)flag
{
    self.statusItemView.isHighlighted = flag;
}


@end
