#import "BackgroundView.h"

#define FILL_OPACITY 1.0f
#define STROKE_OPACITY 1.0f

#define LINE_THICKNESS 1.0f
#define CORNER_RADIUS 10.0f

#define SEARCH_INSET 10.0f

#pragma mark -

@implementation BackgroundView

@synthesize panelCenterX = _panelCenterX;

#pragma mark -

- (void)drawRect:(NSRect)dirtyRect
{
    NSRect contentRect = NSInsetRect([self bounds], LINE_THICKNESS, LINE_THICKNESS);
    NSBezierPath *path = [NSBezierPath bezierPath];
    
    // jump to top center
    [path moveToPoint:NSMakePoint(_panelCenterX, NSMaxY(contentRect))];
    
    // line to top right (no curve)
    [path lineToPoint:NSMakePoint(NSMaxX(contentRect), NSMaxY(contentRect))];
    
    // then down to the beginning of the bottom right corner
    [path lineToPoint:NSMakePoint(NSMaxX(contentRect), NSMinY(contentRect) + CORNER_RADIUS)];
    
    // draw the bottom right corner curve
    NSPoint bottomRightCorner = NSMakePoint(NSMaxX(contentRect), NSMinY(contentRect));
    [path curveToPoint:NSMakePoint(NSMaxX(contentRect) - CORNER_RADIUS, NSMinY(contentRect))
         controlPoint1:bottomRightCorner controlPoint2:bottomRightCorner];
    
    // then draw a line over to the bottom of the bottom left corner
    [path lineToPoint:NSMakePoint(NSMinX(contentRect) + CORNER_RADIUS, NSMinY(contentRect))];
    
    // draw the bottom left corner
    [path curveToPoint:NSMakePoint(NSMinX(contentRect), NSMinY(contentRect) + CORNER_RADIUS)
         controlPoint1:contentRect.origin controlPoint2:contentRect.origin];
    
    // draw up to the top left corner (no curve)
    [path lineToPoint:NSMakePoint(NSMinX(contentRect), NSMaxY(contentRect))];
    
    // then back to the center
    [path lineToPoint:NSMakePoint(_panelCenterX, NSMaxY(contentRect))];
    [path closePath];
    
    // set the fill color
    [[NSColor colorWithDeviceWhite:1 alpha:FILL_OPACITY] setFill];
    [path fill];
    
    [NSGraphicsContext saveGraphicsState];

    NSBezierPath *clip = [NSBezierPath bezierPathWithRect:[self bounds]];
    [clip appendBezierPath:path];
    [clip addClip];
    
    [path setLineWidth:LINE_THICKNESS * 2];
    [[NSColor whiteColor] setStroke];
    [path stroke];
    
    [NSGraphicsContext restoreGraphicsState];
}

#pragma mark -
#pragma mark Public accessors

- (void)setPanelCenterX:(NSInteger)value
{
    _panelCenterX = value;
    [self setNeedsDisplay:YES];
}

@end
