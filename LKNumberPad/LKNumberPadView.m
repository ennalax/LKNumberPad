//
//  LKNumberPadView.m
//  LKNumberPad
//
//  Created by Hiroshi Hashiguchi on 11/07/17.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LKNumberPadView.h"
#import <QuartzCore/QuartzCore.h>

//==============================================================================
// LKNumberPadLayer
//==============================================================================

enum {
    LKNumberPadViewImageLeft = 0,
    LKNumberPadViewImageInner,
    LKNumberPadViewImageRight,
    LKNumberPadViewImageMax
};


@interface LKNumberPadLayer : CALayer {
    CGImageRef keytopImages_[LKNumberPadViewImageMax];
}
@property (nonatomic, copy) NSString* character;
@property (nonatomic, assign) int imageKind;

- (CGImageRef)createKeytopImageWithKind:(int)kind;

@end

@implementation LKNumberPadLayer
@synthesize character;
@synthesize imageKind;

#define LKNUMBERPADVIEW_PAN_SHADOW_OFFSET_X 0
#define LKNUMBERPADVIEW_PAN_SHADOW_OFFSET_Y 5.0
#define LKNUMBERPADVIEW_PAN_SHADOW_BLUR     22.5

#define LKNUMBERPADVIEW_UPPER_WIDTH   54.0
#define LKNUMBERPADVIEW_LOWER_WIDTH   32.0

#define LKNUMBERPADVIEW_PAN_UPPER_RADIUS  8.0
#define LKNUMBERPADVIEW_PAN_LOWER_RADIUS  8.0

#define LKNUMBERPADVIEW_PAN_UPPDER_WIDTH   (LKNUMBERPADVIEW_UPPER_WIDTH-LKNUMBERPADVIEW_PAN_UPPER_RADIUS*2)
#define LKNUMBERPADVIEW_PAN_UPPER_HEIGHT    56.0

#define LKNUMBERPADVIEW_PAN_LOWER_WIDTH     (LKNUMBERPADVIEW_LOWER_WIDTH-LKNUMBERPADVIEW_PAN_LOWER_RADIUS*2)
#define LKNUMBERPADVIEW_PAN_LOWER_HEIGHT    28.0

#define LKNUMBERPADVIEW_PAN_UL_WIDTH        ((LKNUMBERPADVIEW_UPPER_WIDTH-LKNUMBERPADVIEW_LOWER_WIDTH)/2)

#define LKNUMBERPADVIEW_PAN_MIDDLE_HEIGHT    20.0

#define LKNUMBERPADVIEW_PAN_CURVE_SIZE      3.5

#define LKNUMBERPADVIEW_PADDING_X     15
#define LKNUMBERPADVIEW_PADDING_Y     10
#define LKNUMBERPADVIEW_WIDTH   (LKNUMBERPADVIEW_UPPER_WIDTH + LKNUMBERPADVIEW_PADDING_X*2)
#define LKNUMBERPADVIEW_HEIGHT   (LKNUMBERPADVIEW_PAN_UPPER_HEIGHT + LKNUMBERPADVIEW_PAN_MIDDLE_HEIGHT + LKNUMBERPADVIEW_PAN_LOWER_HEIGHT + LKNUMBERPADVIEW_PADDING_Y*2)


#define LKNUMBERPADVIEW_OFFSET_X    -26
#define LKNUMBERPADVIEW_OFFSET_Y    56

- (id)init
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, -LKNUMBERPADVIEW_HEIGHT+LKNUMBERPADVIEW_OFFSET_Y, LKNUMBERPADVIEW_WIDTH, LKNUMBERPADVIEW_HEIGHT);
        for (int i=0; i < LKNumberPadViewImageMax; i++) {
            keytopImages_[i] = [self createKeytopImageWithKind:i];
        }
        self.speed = 10.0;
    }
    return self;
}
- (void)dealloc {
    for (int i=0; i < LKNumberPadViewImageMax; i++) {
        CGImageRelease(keytopImages_[i]);
    }
    [super dealloc];
}

- (CGImageRef)createKeytopImageWithKind:(int)kind
{
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPoint p = CGPointMake(LKNUMBERPADVIEW_PADDING_X, LKNUMBERPADVIEW_PADDING_Y);
    CGPoint p1 = CGPointZero;
    CGPoint p2 = CGPointZero;
    
    p.x += LKNUMBERPADVIEW_PAN_UPPER_RADIUS;
    CGPathMoveToPoint(path, NULL, p.x, p.y);
    
    p.x += LKNUMBERPADVIEW_PAN_UPPDER_WIDTH;
    CGPathAddLineToPoint(path, NULL, p.x, p.y);
    
    p.y += LKNUMBERPADVIEW_PAN_UPPER_RADIUS;
    CGPathAddArc(path, NULL,
                 p.x, p.y,
                 LKNUMBERPADVIEW_PAN_UPPER_RADIUS,
                 3.0*M_PI/2.0,
                 4.0*M_PI/2.0,
                 false);
    
    p.x += LKNUMBERPADVIEW_PAN_UPPER_RADIUS;
    p.y += LKNUMBERPADVIEW_PAN_UPPER_HEIGHT - LKNUMBERPADVIEW_PAN_UPPER_RADIUS - LKNUMBERPADVIEW_PAN_CURVE_SIZE;
    CGPathAddLineToPoint(path, NULL, p.x, p.y);
    
    p1 = CGPointMake(p.x, p.y + LKNUMBERPADVIEW_PAN_CURVE_SIZE);
    switch (kind) {
        case LKNumberPadViewImageLeft:
            p.x -= LKNUMBERPADVIEW_PAN_UL_WIDTH*2;
            break;

        case LKNumberPadViewImageInner:
            p.x -= LKNUMBERPADVIEW_PAN_UL_WIDTH;
            break;

        case LKNumberPadViewImageRight:
            break;
    }

    p.y += LKNUMBERPADVIEW_PAN_MIDDLE_HEIGHT + LKNUMBERPADVIEW_PAN_CURVE_SIZE*2;
    p2 = CGPointMake(p.x, p.y - LKNUMBERPADVIEW_PAN_CURVE_SIZE);
    CGPathAddCurveToPoint(path, NULL,
                          p1.x, p1.y,
                          p2.x, p2.y,
                          p.x, p.y);
    
    p.y += LKNUMBERPADVIEW_PAN_LOWER_HEIGHT - LKNUMBERPADVIEW_PAN_CURVE_SIZE - LKNUMBERPADVIEW_PAN_LOWER_RADIUS;
    CGPathAddLineToPoint(path, NULL, p.x, p.y);

    p.x -= LKNUMBERPADVIEW_PAN_LOWER_RADIUS;
    CGPathAddArc(path, NULL,
                 p.x, p.y,
                 LKNUMBERPADVIEW_PAN_LOWER_RADIUS,
                 4.0*M_PI/2.0,
                 1.0*M_PI/2.0,
                 false);
    
    p.x -= LKNUMBERPADVIEW_PAN_LOWER_WIDTH;
    p.y += LKNUMBERPADVIEW_PAN_LOWER_RADIUS;
    CGPathAddLineToPoint(path, NULL, p.x, p.y);
    
    p.y -= LKNUMBERPADVIEW_PAN_LOWER_RADIUS;
    CGPathAddArc(path, NULL,
                 p.x, p.y,
                 LKNUMBERPADVIEW_PAN_LOWER_RADIUS,
                 1.0*M_PI/2.0,
                 2.0*M_PI/2.0,
                 false);
    
    p.x -= LKNUMBERPADVIEW_PAN_LOWER_RADIUS;
    p.y -= LKNUMBERPADVIEW_PAN_LOWER_HEIGHT - LKNUMBERPADVIEW_PAN_LOWER_RADIUS - LKNUMBERPADVIEW_PAN_CURVE_SIZE;
    CGPathAddLineToPoint(path, NULL, p.x, p.y);
    
    p1 = CGPointMake(p.x, p.y - LKNUMBERPADVIEW_PAN_CURVE_SIZE);

    switch (kind) {
        case LKNumberPadViewImageLeft:
            break;
            
        case LKNumberPadViewImageInner:
            p.x -= LKNUMBERPADVIEW_PAN_UL_WIDTH;
            break;
            
        case LKNumberPadViewImageRight:
            p.x -= LKNUMBERPADVIEW_PAN_UL_WIDTH*2;
            break;
    }

    p.y -= LKNUMBERPADVIEW_PAN_MIDDLE_HEIGHT + LKNUMBERPADVIEW_PAN_CURVE_SIZE*2;
    p2 = CGPointMake(p.x, p.y + LKNUMBERPADVIEW_PAN_CURVE_SIZE);
    CGPathAddCurveToPoint(path, NULL,
                          p1.x, p1.y,
                          p2.x, p2.y,
                          p.x, p.y);
    
    p.y -= LKNUMBERPADVIEW_PAN_UPPER_HEIGHT - LKNUMBERPADVIEW_PAN_UPPER_RADIUS - LKNUMBERPADVIEW_PAN_CURVE_SIZE;
    CGPathAddLineToPoint(path, NULL, p.x, p.y);
    
    p.x += LKNUMBERPADVIEW_PAN_UPPER_RADIUS;
    CGPathAddArc(path, NULL,
                 p.x, p.y,
                 LKNUMBERPADVIEW_PAN_UPPER_RADIUS,
                 2.0*M_PI/2.0,
                 3.0*M_PI/2.0,
                 false);
    //----
    CGContextRef context;
    UIGraphicsBeginImageContext(CGSizeMake(LKNUMBERPADVIEW_WIDTH,
                                           LKNUMBERPADVIEW_HEIGHT));
    context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0, LKNUMBERPADVIEW_HEIGHT);
    CGContextScaleCTM(context, 1.0, -1.0);  // TODO

    CGContextAddPath(context, path);
    CGContextClip(context);
    
    //----

    // draw gradient
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceGray();
    CGFloat components[] = {
        0.95f, 1.0f,
        0.85f, 1.0f,
        0.675f, 1.0f,
        0.8f, 1.0f};
    
    
    size_t count = sizeof(components)/ (sizeof(CGFloat)* 2);
    
    CGRect frame = CGPathGetBoundingBox(path);
    CGPoint startPoint = frame.origin;
    CGPoint endPoint = frame.origin;
    endPoint.y = frame.origin.y + frame.size.height;
    
    CGGradientRef gradientRef =
    CGGradientCreateWithColorComponents(colorSpaceRef, components, NULL, count);
    
    CGContextDrawLinearGradient(context,
                                gradientRef,
                                startPoint,
                                endPoint,
                                kCGGradientDrawsAfterEndLocation);
    
    CGGradientRelease(gradientRef);
    CGColorSpaceRelease(colorSpaceRef);

    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIGraphicsEndImageContext();

    CFRelease(path);
    
    return imageRef;
}

- (void)drawInContext:(CGContextRef)context
{
    CGColorRef shadowColorRef = [[UIColor blackColor] CGColor];
    CGContextSetShadowWithColor(context,
                                CGSizeMake(LKNUMBERPADVIEW_PAN_SHADOW_OFFSET_X,
                                           LKNUMBERPADVIEW_PAN_SHADOW_OFFSET_Y),
                                LKNUMBERPADVIEW_PAN_SHADOW_BLUR,
                                shadowColorRef
                                );

    CGImageRef imageRef = keytopImages_[self.imageKind];
    CGRect imageFrame = CGRectMake(0, 0,
                                   CGImageGetWidth(imageRef),
                                   CGImageGetHeight(imageRef));
    CGContextDrawImage(context, imageFrame, imageRef);

    // draw text
    /*
    CGFontRef font = CGFontCreateWithFontName((CFStringRef)@"Helvetica");
    CGContextSetFont(context, font);
    CGContextSetFontSize(context, 44.0);
    */
    CGContextSelectFont(context, "Helvetica Bold", 44, kCGEncodingMacRoman);
    CGContextSetTextDrawingMode(context, kCGTextFill);
//    CGContextSetGrayFillColor(context, 0.0, 1.0);
    CGContextSetFillColorWithColor(context, [[UIColor blackColor] CGColor]);
    CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0));
    
    shadowColorRef = [[UIColor whiteColor] CGColor];
    CGContextSetShadowWithColor(context,
                                CGSizeMake(0.0,
                                           1.0),
                                1.0,
                                shadowColorRef
                                );
  
    CGContextShowTextAtPoint(context, 30, 55,
                             [self.character UTF8String],
                             [self.character length]);
    
}

@end
    
//==============================================================================
// LKNumberPadView
//==============================================================================
@interface LKNumberPadView()
@property (nonatomic, assign) NSInteger touchedIndex;
@property (nonatomic, retain) NSString* sequentialString;
@property (nonatomic, retain) NSDate* touchedDate;
@property (nonatomic, retain) LKNumberPadLayer* numberPadLayer;
@end

@implementation LKNumberPadView

@synthesize delegate;
@synthesize keyboardColor;
@synthesize textColor;
@synthesize disabledKeyboardColor;
@synthesize disabledTextColor;
@synthesize sequenceInterval;
@synthesize disabledSet;

@synthesize touchedIndex = touchedIndex_;
@synthesize sequentialString = sequentialString_;
@synthesize touchedDate = touchedDate_;
@synthesize numberPadLayer = numberPadLayer_;

#define LKNUMBERPATVIEW_KEYBOARD_NUM    10
#define LKNUMBERPATVIEW_SEQUENTIAL_INTERVAL 0.75

#pragma mark -
#pragma mark Privates



#pragma mark -
#pragma mark Basics
- (void)_setup
{
    self.keyboardColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    self.textColor = [UIColor blackColor];
    self.disabledKeyboardColor = [UIColor colorWithWhite:0.85 alpha:1.0];
    self.disabledTextColor = [UIColor lightGrayColor];
    self.userInteractionEnabled = YES;
    self.touchedIndex = -1;
    self.sequenceInterval = LKNUMBERPATVIEW_SEQUENTIAL_INTERVAL;

    self.numberPadLayer = [LKNumberPadLayer layer];
    [self.layer addSublayer:self.numberPadLayer];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _setup];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self _setup];        
    }
    return self;
}


- (void)dealloc {
    self.keyboardColor = nil;
    self.textColor = nil;
    self.disabledKeyboardColor = nil;
    self.disabledTextColor = nil;
    self.disabledSet = nil;
    [super dealloc];
}

#define LKNUMBERPATVIEW_SHADOW_OFFSET_X    0.0
#define LKNUMBERPATVIEW_SHADOW_OFFSET_Y    1.5
#define LKNUMBERPATVIEW_SHADOW_BLUR        1.5

#define LKNUMBERPATVIEW_KEYBOARD_PADDING_X    3
#define LKNUMBERPATVIEW_KEYBOARD_PADDING_Y    8
#define LKNUMBERPATVIEW_CONNER_RADIUS    4.5

#define LKNUMBERPATVIEW_TEXT_PADDING_X    3
#define LKNUMBERPATVIEW_TEXT_PADDING_Y    8

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();    
    CGRect frame;
    CGColorRef shadowColorRef;
    UIColor* drawColor;

    // (1) draw keyboard
    frame = CGRectMake(0, 0,
                       self.bounds.size.width / LKNUMBERPATVIEW_KEYBOARD_NUM,
                       self.bounds.size.height);
    
    shadowColorRef = [[UIColor blackColor] CGColor];
    CGContextSetShadowWithColor(context,
                                CGSizeMake(LKNUMBERPATVIEW_SHADOW_OFFSET_X,
                                           LKNUMBERPATVIEW_SHADOW_OFFSET_Y),
                                LKNUMBERPATVIEW_SHADOW_BLUR,
                                shadowColorRef
                                );

    for (int i=0; i < LKNUMBERPATVIEW_KEYBOARD_NUM; i++) {
        CGRect buttonFrame = CGRectInset(frame,
                                         LKNUMBERPATVIEW_KEYBOARD_PADDING_X,
                                         LKNUMBERPATVIEW_KEYBOARD_PADDING_Y);
        UIBezierPath* path = [UIBezierPath bezierPathWithRoundedRect:buttonFrame
                                                        cornerRadius:LKNUMBERPATVIEW_CONNER_RADIUS];

        if ([self.disabledSet containsObject:[NSNumber numberWithInt:i]]) {
            // disabled
            drawColor = self.disabledKeyboardColor;
        } else {
            // enabled
            drawColor = self.keyboardColor;
        }
        [drawColor set];
    
        [path fill];
        frame.origin.x += frame.size.width;
    }
    
    // (2) draw string
    shadowColorRef = [[UIColor whiteColor] CGColor];
    CGContextSetShadowWithColor(context,
                                CGSizeMake(0,
                                           1),
                                0,
                                shadowColorRef
                                );

    frame = CGRectMake(0, 0,
                       self.bounds.size.width / LKNUMBERPATVIEW_KEYBOARD_NUM,
                       self.bounds.size.height);

    UIFont* font = [UIFont boldSystemFontOfSize:21.0];
    
    for (int i=0; i < LKNUMBERPATVIEW_KEYBOARD_NUM; i++) {
        NSString* string = [NSString stringWithFormat:@"%d", (i+1)%LKNUMBERPATVIEW_KEYBOARD_NUM];
        CGSize size = [string sizeWithFont:font];
        CGRect textFrame = CGRectInset(frame,
                                       LKNUMBERPATVIEW_KEYBOARD_PADDING_X
                                       +LKNUMBERPATVIEW_TEXT_PADDING_X,
                                       LKNUMBERPATVIEW_KEYBOARD_PADDING_Y
                                       +LKNUMBERPATVIEW_TEXT_PADDING_Y);
        textFrame.origin.x += (textFrame.size.width - size.width)/2.0;
        textFrame.origin.y += (textFrame.size.height - size.height)/2.0;

        if ([self.disabledSet containsObject:[NSNumber numberWithInt:i]]) {
            // disabled
            drawColor = self.disabledTextColor;
        } else {
            // enabled
            drawColor = self.textColor;
        }
        [drawColor set];
        [string drawAtPoint:textFrame.origin withFont:font];
        frame.origin.x += frame.size.width;
    }

}

#pragma mark -
#pragma mark Actions
- (NSUInteger)_indexWithEvent:(UIEvent*)event
{
    UITouch* touch = [[event allTouches] anyObject];
    NSUInteger index = [touch locationInView:nil].x / (self.bounds.size.width / LKNUMBERPATVIEW_KEYBOARD_NUM);
    return index;
}

- (void)_updateWithIndex:(NSUInteger)index
{
    self.touchedIndex = index;
    NSUInteger number = (index+1)%LKNUMBERPATVIEW_KEYBOARD_NUM;
    
    if ([self.disabledSet containsObject:[NSNumber numberWithUnsignedInteger:index]]) {
        return;
        // disabled
    }

    CGRect numberPadFrame = self.numberPadLayer.frame;
    numberPadFrame.origin.x = (self.bounds.size.width / LKNUMBERPATVIEW_KEYBOARD_NUM) * index + LKNUMBERPADVIEW_OFFSET_X;
    if (index == 0) {
        self.numberPadLayer.imageKind = LKNumberPadViewImageLeft;
        numberPadFrame.origin.x += LKNUMBERPADVIEW_PAN_UL_WIDTH;
    } else if (index == LKNUMBERPATVIEW_KEYBOARD_NUM-1) {
        self.numberPadLayer.imageKind = LKNumberPadViewImageRight;
        numberPadFrame.origin.x -= LKNUMBERPADVIEW_PAN_UL_WIDTH;
    } else {
        self.numberPadLayer.imageKind = LKNumberPadViewImageInner;
    }
    self.numberPadLayer.frame = numberPadFrame;
    self.numberPadLayer.character = [NSString stringWithFormat:@"%d",
                                     (index+1)%LKNUMBERPATVIEW_KEYBOARD_NUM];
    
    [self setNeedsDisplay];
    [self.numberPadLayer setNeedsDisplay];

    NSTimeInterval intervalSinceNow = -[self.touchedDate timeIntervalSinceNow];
    if (intervalSinceNow < self.sequenceInterval) {
        if (!self.sequentialString) {
            self.sequentialString = @"";
        }
    } else {
        self.sequentialString = @"";        
    }
    self.sequentialString = [NSString stringWithFormat:@"%@%d",
                             self.sequentialString, number];

    self.touchedDate = [NSDate date];
    
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(didTouchNumberPadView:withNumber:)]) {
            [self.delegate didTouchNumberPadView:self withNumber:number];
        }
        if ([self.delegate respondsToSelector:@selector(didTouchNumberPadView:withSequentialString:)]) {
            [self.delegate didTouchNumberPadView:self withSequentialString:self.sequentialString];
        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSUInteger index = [self _indexWithEvent:event];
    self.numberPadLayer.opacity = 1.0;
    [self _updateWithIndex:index];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSUInteger index = [self _indexWithEvent:event];
    if (index != self.touchedIndex) {
        [self _updateWithIndex:index];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.touchedIndex = -1;
    self.numberPadLayer.opacity = 0.0;
    [self setNeedsDisplay];
}


#pragma mark -
#pragma mark Properties



@end
