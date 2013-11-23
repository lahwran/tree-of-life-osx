#define STATUS_ITEM_VIEW_WIDTH 24.0

#pragma mark -

@class StatusItemView;

@interface MenubarController : NSObject {
@private
    StatusItemView *_statusItemView;
    NSArray *text;
    int _max_width;
}

@property (nonatomic) BOOL hasActiveIcon;
@property (nonatomic) int max_width;
@property (nonatomic, strong, readonly) NSStatusItem *statusItem;
@property (nonatomic, strong, readonly) StatusItemView *statusItemView;
@property (retain, nonatomic) NSArray *text;


@end
