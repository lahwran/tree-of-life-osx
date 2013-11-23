//
//  TextFieldDelegate.h
//  Popup
//
//  Created by lahwran on 9/7/12.
//
//

#import <Foundation/Foundation.h>

@interface TextFieldDelegate : NSObject <NSTextFieldDelegate> {
    __unsafe_unretained id _delegate;
}

@property (unsafe_unretained, nonatomic) id delegate;

- (id)initWithDelegate:(id)delegate;
- (BOOL)control:(NSControl *)control textView:(NSTextView *)fieldEditor doCommandBySelector:(SEL)commandSelector;

@end
