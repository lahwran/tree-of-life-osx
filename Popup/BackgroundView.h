#define ARROW_WIDTH 20
#define ARROW_HEIGHT 20

@interface BackgroundView : NSView
{
    NSInteger _panelCenterX;
}

@property (nonatomic, assign) NSInteger panelCenterX;

@end
