//
//  ViewController.h
//  MovingCounter
//
//  Created by Bernd Rabe on 31.01.14.
//  Copyright (c) 2014 Bernd Rabe. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MovingCounterView;

@interface ViewController : UIViewController
@property (nonatomic, weak) IBOutlet MovingCounterView *mcView;
@end
