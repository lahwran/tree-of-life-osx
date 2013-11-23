//
//  TextFieldDelegate.m
//  Popup
//
//  Created by lahwran on 9/7/12.
//
//

#import "TextFieldDelegate.h"

@implementation TextFieldDelegate

- (id)initWithDelegate:(id)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
    }
    return self;
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)fieldEditor doCommandBySelector:(SEL)commandSelector {
    NSString *direction = nil;

    if (commandSelector == @selector(moveUp:)) {
        direction = @"up";
    } else if (commandSelector == @selector(moveDown:)) {
        direction = @"down";
    }
    
    if (direction != nil && [self.delegate respondsToSelector:@selector(navigateHistory:)]) {
        [self.delegate performSelector:@selector(navigateHistory:) withObject:direction];
        return YES;
    }
    
    return NO;
}

@end
