@interface StatusItemView : NSView {
@private
    NSStatusItem *_statusItem;
    NSString *parentText;
    NSString *mainText;
    BOOL _isHighlighted;
    SEL _action;
    __unsafe_unretained id _target;
}

@property (nonatomic, strong) NSStatusItem *statusItem;
@property (nonatomic, setter = setHighlighted:) BOOL isHighlighted;
@property (nonatomic, readonly) NSRect globalRect;
@property (nonatomic) SEL action;
@property (nonatomic, unsafe_unretained) id target;
@property (retain, nonatomic) NSString *parentText;
@property (retain, nonatomic) NSString *mainText;

- (int) getTextWidth:(NSString*)some_parent_text mainText:(NSString*)some_main_text;

@end
