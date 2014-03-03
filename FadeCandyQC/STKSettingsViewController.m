//
//  STKSettingsViewController.m
//  FadeCandyQC
//
//  Created by Noah Emmet on 3/3/14.
//  Copyright (c) 2014 Sticks. All rights reserved.
//

#import "STKSettingsViewController.h"
@interface STKSettingsViewController ()
@property (weak) IBOutlet NSForm *hostForm;
@property (weak) IBOutlet NSForm *portForm;
@property (weak) IBOutlet NSForm *pixelWidthForm;
@property (weak) IBOutlet NSForm *pixelHeightForm;
@property (weak) IBOutlet NSButtonCell *zigzagCheckbox;
@property (weak) IBOutlet NSButtonCell *pixelOrderCell;

@end

@implementation STKSettingsViewController
// Network
-(NSString*)host{
	if (self.hostForm.stringValue.length > 0){
		return self.hostForm.stringValue;
	}else{
		return @"localhost";
	}
}

-(uint16_t)port{
	if (self.portForm.stringValue.length > 0){
		return self.portForm.integerValue;
	}else{
		return 7890;
	}
}

// Shape
-(NSUInteger)pixelWidth{
	if (self.pixelWidthForm.stringValue.length > 0){
		return self.pixelWidthForm.integerValue;
	}else{
		return 6;
	}
}

-(NSUInteger)pixelHeight{
	if (self.pixelHeightForm.stringValue.length > 0){
		return self.pixelHeightForm.integerValue;
	}else{
		return 8;
	}
}

-(STKPixelColorOrder)pixelOrder{
	return [self.pixelOrderCell state];
}

-(BOOL)isZigzag{
	return [self.zigzagCheckbox state];
}

@end
