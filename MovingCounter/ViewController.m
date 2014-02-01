//
//  ViewController.m
//  MovingCounter
//
//  Created by Bernd Rabe on 31.01.14.
//  Copyright (c) 2014 Bernd Rabe. All rights reserved.
//

#import "ViewController.h"
#import "MovingCounterView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startAnimation:(id)sender
{
    CGFloat yPosition = CGRectGetHeight(self.mcView.bounds) - 20.f;
    self.mcView.targetCount = 200;
    
    [self.mcView startMarkerAnimationToYPosition:yPosition duration:4];
}

@end
