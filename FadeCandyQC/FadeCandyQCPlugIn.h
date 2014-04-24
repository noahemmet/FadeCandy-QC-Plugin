//
//  FadeCandyQCPlugIn.h
//  FadeCandyQC
//
//  Created by Noah Emmet on 2/20/14.
//  Copyright (c) 2014 Sticks. All rights reserved.
//

#import <Quartz/Quartz.h>

typedef NS_ENUM(NSInteger, STKPixelOrder) {
    STKPixelOrderRGB,
    STKPixelOrderBRG,
    STKPixelOrderGBR,
};

@interface FadeCandyQCPlugIn : QCPlugIn

@property id<QCPlugInInputImageSource> inputImage;

@end
