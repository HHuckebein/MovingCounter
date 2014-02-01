//
//  MovingCounterView.h
//  MovingCounter
//
//  Created by Bernd Rabe on 31.01.14.
//  Copyright (c) 2014 Bernd Rabe. All rights reserved.
//
/** Demonstrates a combined position/value animation. */

#import <UIKit/UIKit.h>

@interface MovingCounterView : UIView

@property (nonatomic, assign) NSInteger targetCount;

- (void)startMarkerAnimationToYPosition:(CGFloat)yPos duration:(CFTimeInterval)duration;

@end
