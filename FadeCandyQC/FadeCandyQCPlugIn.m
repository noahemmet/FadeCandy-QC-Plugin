//
//  FadeCandyQCPlugIn.m
//  FadeCandyQC
//
//  Created by Noah Emmet on 2/20/14.
//  Copyright (c) 2014 Sticks. All rights reserved.
//

// It's highly recommended to use CGL macros instead of changing the current context for plug-ins that perform OpenGL rendering
#import <OpenGL/CGLMacro.h>
#import <GCDAsyncSocket.h>

#import "FadeCandyQCPlugin.h"
#import "STKSettingsViewController.h"

#define	kQCPlugIn_Name				@"FadeCandy"
#define	kQCPlugIn_Description		@"Lets you output visuals to a locally running FadeCandy server."

@interface FadeCandyQCPlugIn () <GCDAsyncSocketDelegate>
@property GCDAsyncSocket *socket;
@property STKSettingsViewController *settingsViewController;
// Settings
@property STKPixelColorOrder pixelOrder;
@property NSString *host;
@property uint16_t port;
@end

@implementation FadeCandyQCPlugIn
@dynamic inputImage;
// Here you need to declare the input / output properties as dynamic as Quartz Composer will handle their implementation
//@dynamic inputFoo, outputBar;

+ (NSDictionary *)attributes
{
	// Return a dictionary of attributes describing the plug-in (QCPlugInAttributeNameKey, QCPlugInAttributeDescriptionKey...).
    return @{QCPlugInAttributeNameKey:kQCPlugIn_Name, QCPlugInAttributeDescriptionKey:kQCPlugIn_Description};
}

+ (NSDictionary *)attributesForPropertyPortWithKey:(NSString *)key
{
	// Specify the optional attributes for property based ports (QCPortAttributeNameKey, QCPortAttributeDefaultValueKey...).
	//	return nil;
	if([key isEqualToString:@"inputImage"])
		return @{@"Image": QCPortAttributeNameKey};
	return nil;
}

+(NSArray *)plugInKeys{
	return @[@"pixelOrder", @"host", @"port"];
}

+ (QCPlugInExecutionMode)executionMode
{
	// Return the execution mode of the plug-in: kQCPlugInExecutionModeProvider, kQCPlugInExecutionModeProcessor, or kQCPlugInExecutionModeConsumer.
	return kQCPlugInExecutionModeConsumer;
}

+ (QCPlugInTimeMode)timeMode
{
	// Return the time dependency mode of the plug-in: kQCPlugInTimeModeNone, kQCPlugInTimeModeIdle or kQCPlugInTimeModeTimeBase.
	return kQCPlugInTimeModeTimeBase;
}

- (id)init
{
	self = [super init];
	if (self)
	{
		// Allocate any permanent resource required by the plug-in.
		_socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
		_socket.delegate = self;
		
	}
	
	return self;
}

@end

#pragma mark - Execution

@implementation FadeCandyQCPlugIn (Execution)

- (BOOL)startExecution:(id <QCPlugInContext>)context
{
	// Called by Quartz Composer when rendering of the composition starts: perform any required setup for the plug-in.
	// Return NO in case of fatal failure (this will prevent rendering of the composition to start).
	NSError *error;
	//	[self.socket connectToHost:@"localhost" onPort:7890 viaInterface:@"localhost" withTimeout:5 error:&error];
	if (error)
	{
		NSLog(@"error connecting to fc: %@", error);
	}
	
	
	return YES;
}

- (void)enableExecution:(id <QCPlugInContext>)context
{
	// Called by Quartz Composer when the plug-in instance starts being used by Quartz Composer.
	
	//	if (self.socket.connectedHost){
	//		UInt8 bytes[10] = {0,0x00,0,6,000,000,100,100,200,200};
	//		NSData *data = [NSData dataWithBytes:bytes length:10]; // length needs to be 0;
	//		[self.socket writeData:data withTimeout:5 tag:1];
	//	}
	NSError *error;
	[self.socket connectToHost:[self.settingsViewController host] onPort:[self.settingsViewController port] viaInterface:@"localhost" withTimeout:5 error:&error];
	if (error)
	{
		NSLog(@"error connecting to fc: %@", error);
	}
}

- (BOOL)execute:(id <QCPlugInContext>)context atTime:(NSTimeInterval)time withArguments:(NSDictionary *)arguments
{
	//	NSLog(@"bounds: %@", NSStringFromRect([context bounds]));
	//	NSLog(@"1");
	//	CGLContextObj cgl_ctx = [context CGLContextObj];
	id <QCPlugInInputImageSource> qcImage = [self inputImage];
	NSString*						pixelFormat;
	CGColorSpaceRef					colorSpace;
	CGDataProviderRef				dataProvider;
	
	
	
	
	/* Figure out pixel format and colorspace to use */
	colorSpace = [qcImage imageColorSpace];
	if(CGColorSpaceGetModel(colorSpace) == kCGColorSpaceModelMonochrome)
		pixelFormat = QCPlugInPixelFormatI8;
	else if(CGColorSpaceGetModel(colorSpace) == kCGColorSpaceModelRGB)
#if __BIG_ENDIAN__
		pixelFormat = QCPlugInPixelFormatARGB8;
#else
	pixelFormat = QCPlugInPixelFormatBGRA8;
#endif
	else
		return NO;
	
	/* Get a buffer representation from the image in its native colorspace */
	if(![qcImage lockBufferRepresentationWithPixelFormat:pixelFormat colorSpace:colorSpace forBounds:[qcImage imageBounds]])
	{
		return YES;
	}
	
	/* Create CGImage from buffer */
	dataProvider = CGDataProviderCreateWithData(NULL, [qcImage bufferBaseAddress], ([qcImage bufferPixelsHigh] * [qcImage bufferBytesPerRow]), NULL);
	//	CGImageRef cgImageRef = CGImageCreate([qcImage bufferPixelsWide], [qcImage bufferPixelsHigh], 8, (pixelFormat == QCPlugInPixelFormatI8 ? 8 : 32), [qcImage bufferBytesPerRow], colorSpace, (pixelFormat == QCPlugInPixelFormatI8 ? 0 : kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host), dataProvider, NULL, false, kCGRenderingIntentDefault);
	CGImageRef cgImageRef;
	cgImageRef = CGImageCreate([qcImage bufferPixelsWide],	// Width
							   [qcImage bufferPixelsHigh],	// Height
							   8,							// Bits per component
							   32,							// Bits per pixel
							   [qcImage bufferBytesPerRow],	// Bytes per row
							   colorSpace,					// Colorspace
							   kCGImageAlphaNone,			// BitmapInfo
							   dataProvider,				// Data provider
							   NULL,							// Decode
							   false,						// Should interpolate
							   kCGRenderingIntentDefault);	// Rendering intent
	CGDataProviderRelease(dataProvider);
	
//	NSImage *nsImage = [NSImage alloc];
//    nsImage = [nsImage initWithCGImage: cgImageRef size: [qcImage imageBounds].size];
	
	
	CFDataRef data = CGDataProviderCopyData(CGImageGetDataProvider(cgImageRef));
	const UInt8 *pixelDataWithAlpha = CFDataGetBytePtr(data);
	
	
	NSUInteger numPixels = [self.settingsViewController pixelWidth] * [self.settingsViewController pixelHeight];
	NSUInteger numPixelBytes = numPixels * 3;
	
	UInt8 pixelData[numPixelBytes];
	
	NSUInteger pixelWidth = [self.settingsViewController pixelWidth];
	NSUInteger pixelHeight = [self.settingsViewController pixelHeight];
	BOOL isZigZag = [self.settingsViewController isZigzag];
	STKPixelColorOrder pixelOrder = [self.settingsViewController pixelOrder];
	
	// Manual override
	pixelOrder = STKPixelColorOrderBRG;
	isZigZag = YES;
	
	NSUInteger byteIndex = 0;
	for (int counter = 0; counter < numPixelBytes; counter += 3)
	{
		
		if (counter > 0 && (counter % byteIndex) % 18 == 0)
		{
			// TODO: Blank space handling.
			// This handles weird blank space. I think if it's if the image bounds are under a certain amount. Right now it's just detecting a red of 0; that will have to change
			// ByteIndex: 24 - 63, 88, 152
			// Counter: 18, 36, 54
			byteIndex += 40;
		}
		UInt8 red   = pixelDataWithAlpha[byteIndex];
        UInt8 green = pixelDataWithAlpha[byteIndex + 1];
		UInt8 blue  = pixelDataWithAlpha[byteIndex + 2];
		
		
		NSUInteger pixelIndex = counter / 3;
		NSUInteger row = pixelIndex / pixelWidth;
		BOOL isAltRow = (row % 2);
		
		NSUInteger indexToWrite;
		if (isZigZag && isAltRow)
		{
			NSUInteger pixelsFromEndOfRow = (pixelIndex % pixelWidth);
			indexToWrite = (row * pixelWidth * 3) - (pixelsFromEndOfRow * 3) + (pixelWidth * 3) - 3;
		}
		else
		{
			indexToWrite = counter;
		}
		
		switch (pixelOrder)
		{
			case STKPixelColorOrderRGB:
				pixelData[indexToWrite]		= red;
				pixelData[indexToWrite + 1] = green;
				pixelData[indexToWrite + 2] = blue;
				break;
			case STKPixelColorOrderBRG:
				pixelData[indexToWrite]		= blue;
				pixelData[indexToWrite + 1] = red;
				pixelData[indexToWrite + 2] = green;
				break;
			case STKPixelColorOrderGBR:
				pixelData[indexToWrite]		= green;
				pixelData[indexToWrite + 1] = blue;
				pixelData[indexToWrite + 2] = red;
				break;
				
			default:
				break;
		}
		
		byteIndex += 4;
	}
	
	if (self.socket.connectedHost)
	{
		UInt8 channel = 0;
		const UInt8 command = 0x00;
		UInt8 length1 = 0;
		UInt8 length2 = numPixelBytes;
		
		const UInt8 headerLength = 4;
		UInt8 opcHeader[headerLength] = {channel, command, length1, length2};
		
		NSMutableData *bytes = [[NSMutableData alloc]initWithBytes:opcHeader length:4];
		[bytes appendData:[NSData dataWithBytes:(UInt8*)pixelData length:numPixelBytes]];
		
		if (bytes.length == (numPixelBytes + headerLength)){
			[self.socket writeData:bytes withTimeout:5 tag:1];
		}
	}
	//	free(colors);
	
	/*
	 Called by Quartz Composer whenever the plug-in instance needs to execute.
	 Only read from the plug-in inputs and produce a result (by writing to the plug-in outputs or rendering to the destination OpenGL context) within that method and nowhere else.
	 Return NO in case of failure during the execution (this will prevent rendering of the current frame to complete).
	 
	 The OpenGL context for rendering can be accessed and defined for CGL macros using:
	 CGLContextObj cgl_ctx = [context CGLContextObj];
	 */
	
	return YES;
}

- (void)disableExecution:(id <QCPlugInContext>)context
{
	// Called by Quartz Composer when the plug-in instance stops being used by Quartz Composer.
	[self.socket disconnectAfterWriting];
}

- (void)stopExecution:(id <QCPlugInContext>)context
{
	// Called by Quartz Composer when rendering of the composition stops: perform any required cleanup for the plug-in.
}

@end


#pragma mark - Settings

@interface FadeCandyQCPlugIn (Settings)
@end

@implementation FadeCandyQCPlugIn (Settings)

-(STKSettingsViewController*)settingsViewController{
	if (!_settingsViewController){
		_settingsViewController = [[STKSettingsViewController alloc]initWithPlugIn:self viewNibName:@"STKSettingsViewController"];
	}
	return _settingsViewController;
}

-(QCPlugInViewController *)createViewController{
	return self.settingsViewController;
}

//+(NSArray *)plugInKeys{
//	return @[@"pixelOrder"];
//}
@end

@implementation FadeCandyQCPlugIn (Network)

#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sender didConnectToHost:(NSString *)host port:(UInt16)port
{
	//    NSLog(@"Cool, I'm connected! That was easy.");
	if (self.socket.connectedHost){
		//		UInt8 bytes[10] = {0,0x00,0,6,000,000,000,100,5,5};
		//		NSData *data = [NSData dataWithBytes:bytes length:10];
		//		[self.socket writeData:data withTimeout:5 tag:1];
	}
}

-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
	//	NSLog(@"Disconnected");
}

-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
	//	NSLog(@"did write");
}

-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
	//	NSLog(@"read: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
}

@end
