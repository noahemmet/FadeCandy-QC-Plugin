//
//  STKSettingsViewController.h
//  FadeCandyQC
//
//  Created by Noah Emmet on 3/3/14.
//  Copyright (c) 2014 Sticks. All rights reserved.
//

#import <Quartz/Quartz.h>
#import "FadeCandyQCPlugIn.h"

@interface STKSettingsViewController : QCPlugInViewController
// Network
-(NSString*)host;
-(uint16_t)port;

// Shape
-(NSUInteger)pixelWidth;
-(NSUInteger)pixelHeight;
-(BOOL)isZigzag;
-(STKPixelColorOrder)pixelOrder;
@end
