//
//  MovingCounterView.m
//  MovingCounter
//
//  Created by Bernd Rabe on 31.01.14.
//  Copyright (c) 2014 Bernd Rabe. All rights reserved.
//

#import "MovingCounterView.h"

#define MOVING_COUNTER_DEBUG    0

#define VIEW_WIDTH              26.f

#define COUNT_KEY               @"count"

@interface CountingLayer : CALayer
@property (nonatomic) NSInteger count;
@end

@interface MovingCounterView()
@property (nonatomic) CountingLayer         *markerLayer;
@property (nonatomic) CALayer               *rightSideLayer;
@property (nonatomic) CATextLayer           *infoTextLayer;
@property (nonatomic) NSDictionary          *infoTextStyleAttributes;
@property (nonatomic) CAMediaTimingFunction *timingFunction;
@property (nonatomic) NSString              *displayFormatString;
@end

@implementation MovingCounterView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    if (MOVING_COUNTER_DEBUG) {
        self.layer.borderColor = [UIColor redColor].CGColor;
        self.layer.borderWidth = 1.;
    }
    
    _timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    _displayFormatString = @"Current Count %@";
    
    self.backgroundColor = [UIColor clearColor];
    [self.layer addSublayer:self.rightSideLayer];
}

#pragma mark - Right Side (beside Todesfallabsicherung) Layer

- (CALayer *)rightSideLayer
{
    UIImage *image = [[UIImage imageNamed:@"RightBar"] resizableImageWithCapInsets:UIEdgeInsetsMake(9, 25, 1, 25)];
    
    if (nil == _rightSideLayer && image) {
        _rightSideLayer                 = [CALayer layer];
        _rightSideLayer.contentsScale   = [[UIScreen mainScreen] scale];
        
        CGFloat width                   = image.size.width;
        CGFloat height                  = CGRectGetHeight(self.bounds);
        _rightSideLayer.contentsCenter  = CGRectMake(25.f/width, 1.f/height, 1.f/width, 9./height);
        _rightSideLayer.frame           = CGRectMake(0.f, 0.f, 25.f, CGRectGetHeight(self.bounds));
        
        _rightSideLayer.contents        = (id)image.CGImage;
        
        [_rightSideLayer addSublayer:self.markerLayer];
        [_rightSideLayer addSublayer:self.infoTextLayer];
        
        if (MOVING_COUNTER_DEBUG) {
            _rightSideLayer.borderColor = [UIColor blueColor].CGColor;
            _rightSideLayer.borderWidth = 1.;
        }
    }
    return _rightSideLayer;
}

#pragma mark - Right Side Marker Layer (Circle + Bar) + InfoText

- (CountingLayer *)markerLayer
{
    UIImage *image = [UIImage imageNamed:@"CircleWithRightBar"];
    if (nil == _markerLayer && image) {
        CGFloat height       = image.size.height;
        CGFloat bottomMargin = 2.f;
        CGFloat xOrigin      = 6.f;
        CGFloat yOrigin      = CGRectGetHeight(self.bounds) - height - bottomMargin;
        
        CGRect frame = CGRectMake(xOrigin, yOrigin, VIEW_WIDTH, height);
        
        _markerLayer                = [CountingLayer layer];
        _markerLayer.contentsScale  = [[UIScreen mainScreen] scale];
        _markerLayer.frame          = frame;
        _markerLayer.delegate       = self;
        _markerLayer.contents       = (id)image.CGImage;
        
        if (MOVING_COUNTER_DEBUG) {
            _markerLayer.borderColor = [UIColor yellowColor].CGColor;
            _markerLayer.borderWidth = 1.;
        }
    }
    return _markerLayer;
}

- (CATextLayer *)infoTextLayer
{
    if (nil == _infoTextLayer) {
        _infoTextLayer                = [CATextLayer layer];
        _infoTextLayer.contentsScale  = [[UIScreen mainScreen] scale];
        
        NSAttributedString *aText     = [self attributedStringWithCount:1000];
        
        CGFloat margin                = 5.f;
        CGRect frame                  = [self textLayerFrameForText:aText.string boundingRect:CGRectMake(0, 0, 150, 50)];
        frame.origin                  = _markerLayer.frame.origin;
        frame.origin.x               += (CGRectGetWidth(_markerLayer.bounds) + margin);
        frame.origin.y               -= floorf((CGRectGetHeight(_markerLayer.bounds) - CGRectGetHeight(frame)) / 2);
        _infoTextLayer.frame          = frame;

        _infoTextLayer.alignmentMode  = kCAAlignmentLeft;
        _infoTextLayer.string         = [self attributedStringWithCount:0];
        
        if (MOVING_COUNTER_DEBUG) {
            _infoTextLayer.borderColor = [UIColor blueColor].CGColor;
            _infoTextLayer.borderWidth = 1.;
        }
    }
    return _infoTextLayer;
}

- (NSAttributedString *)attributedStringWithCount:(NSInteger)count
{
    NSString *string = [NSString stringWithFormat:self.displayFormatString, @(count)];
    NSAttributedString *aString = [[NSAttributedString alloc] initWithString:string attributes:self.infoTextStyleAttributes];
    
    return aString;
}

- (CGRect)textLayerFrameForText:(NSString *)text boundingRect:(CGRect)rect
{
    CGRect textLayerFrame = [text boundingRectWithSize:rect.size
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:self.infoTextStyleAttributes
                                               context:[[NSStringDrawingContext alloc] init]];
    
    return CGRectIntegral(textLayerFrame);
}

- (NSDictionary *)infoTextStyleAttributes
{
    if (nil == _infoTextStyleAttributes) {
        NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
        paraStyle.alignment                = NSTextAlignmentLeft;
        
        _infoTextStyleAttributes =@{NSParagraphStyleAttributeName : paraStyle};
    }
    return _infoTextStyleAttributes;
}

- (void)startMarkerAnimationToYPosition:(CGFloat)yPos duration:(CFTimeInterval)duration
{
    CFTimeInterval now = [self.rightSideLayer convertTime:CACurrentMediaTime() fromLayer:nil];
    
    // position animation
    CABasicAnimation *posAnim = [self posAnimationForLayer:self.markerLayer beginTime:now duration:duration yPosition:yPos];;
    self.markerLayer.position = [posAnim.toValue CGPointValue];
    [self.markerLayer addAnimation:posAnim forKey:@"position"];

    posAnim = [self posAnimationForLayer:self.infoTextLayer beginTime:now duration:duration yPosition:yPos];
    self.infoTextLayer.position = [posAnim.toValue CGPointValue];
    [self.infoTextLayer addAnimation:posAnim forKey:@"position"];

    // moving count animation
    CABasicAnimation *countAnim = [CABasicAnimation animationWithKeyPath:COUNT_KEY];

    countAnim.fromValue         = @(0);
    countAnim.toValue           = @(self.targetCount);

    countAnim.beginTime         = now;
    countAnim.duration          = duration;

    countAnim.timingFunction    = self.timingFunction;
    
    self.markerLayer.count      = self.targetCount;
    [self.markerLayer addAnimation:countAnim forKey:COUNT_KEY];
    
}

- (CABasicAnimation *)posAnimationForLayer:(CALayer *)layer beginTime:(CFTimeInterval)beginTime duration:(NSTimeInterval)duration yPosition:(CGFloat)yPos
{
    CABasicAnimation *posAnim = [CABasicAnimation animationWithKeyPath:@"position"];
    CGPoint point             = layer.position;
    posAnim.fromValue         = [NSValue valueWithCGPoint:point];
    
    point.y                  -= yPos;
    posAnim.toValue           = [NSValue valueWithCGPoint:point];
    posAnim.duration          = duration;
    posAnim.beginTime         = beginTime;
    posAnim.timingFunction    = self.timingFunction;
    
    return posAnim;
}

#pragma mark - CALayer Delegate

- (void)displayLayer:(CALayer *)layer
{
    if ([layer isKindOfClass:[CountingLayer class]]) {
        NSInteger currentCount = [[layer.presentationLayer valueForKey:COUNT_KEY] integerValue];
        self.infoTextLayer.string = [self attributedStringWithCount:currentCount];
    }
}

@end

@implementation CountingLayer

@dynamic count;

+ (BOOL)needsDisplayForKey:(NSString *)key
{
    return [key isEqualToString:COUNT_KEY] || [super needsDisplayForKey:key];
}

@end
