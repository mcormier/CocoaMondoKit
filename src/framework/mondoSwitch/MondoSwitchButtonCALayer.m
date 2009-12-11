//
//  MondoSwitchButtonCALayer.m
//  CocoaMondoKit
//
//  Created by Matthieu Cormier on 12/8/09.
//  Copyright 2009 Preen and Prune Software and Design. All rights reserved.
//

#import "MondoSwitchButtonCALayer.h"
#import "PPCommon.h"

#define WHITE_COLOR CGColorCreateGenericRGB(1.0f,1.0f,1.0f,1.0f)
#define GREY_COLOR CGColorCreateGenericRGB(0.95294118f,0.95294118f,0.95294118f,1.0f)
#define BLUE_COLOR CGColorCreateGenericRGB(0.0f,0.0f,1.0f,1.0f)

// TODO use button gradient of 253 -> 230

@interface MondoSwitchButtonCALayer (PrivateMethods)
- (void)createtheSwitch;
- (void)switchSide;
- (void)moveSwitch:(CGFloat)dx;
@end

@implementation MondoSwitchButtonCALayer

@synthesize on;

- (id) init {
  [super init];
  self.autoresizingMask = kCALayerWidthSizable;
  self.cornerRadius = 5.0;
  self.masksToBounds = YES;
  self.borderWidth = 0;
  //self.borderColor = WHITE_COLOR;
  //self.backgroundColor = WHITE_COLOR;
  self.bounds = CGRectMake(00, 00, 20, 20);
  self.anchorPoint = CGPointMake(0.0, 0.0);

  //self.opacity = 0.0;
  
  //self.frame = CGRectMake(0, 0, 40, 40);
  [self addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMinY relativeTo:@"superlayer" attribute:kCAConstraintMinY]];
  [self addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMinX relativeTo:@"superlayer" attribute:kCAConstraintMinX]];
  
	[self addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintWidth relativeTo:@"superlayer" attribute:kCAConstraintWidth]];  
  [self addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintHeight relativeTo:@"superlayer" attribute:kCAConstraintHeight]];  
  [self setLayoutManager:[CAConstraintLayoutManager layoutManager]];
  
  [self createtheSwitch];
  _currentEventState = PPNoEvent;
  
  return self;
}




#pragma mark -
#pragma mark mouse events

-(void)mouseDown:(CGPoint)point {
  _currentEventState = CGRectContainsPoint ( theSwitch.frame, point )  
                       ? PPcanDragSwitch : PPstandardMouseDown;
}

-(void)mouseUp:(CGPoint)point {
    [self switchSide];
}


-(void)mouseDragged:(CGPoint)point {
  
  if (_currentEventState == PPdragOccurred ||  _currentEventState == PPcanDragSwitch) {
    _currentEventState = PPdragOccurred;
    [self moveSwitch:point.x];   
  }
  
}

- (void)setOn:(BOOL)on animated:(BOOL)animated {
  NSLog(@"Stub method...");
}

@end

@implementation MondoSwitchButtonCALayer (PrivateMethods)

- (void) createtheSwitch {
  theSwitch = [CALayer layer];
  [theSwitch retain];
  
  CGFloat radius = 5.0;
  
  theSwitch.cornerRadius = radius;
  theSwitch.masksToBounds = YES;
  theSwitch.borderWidth = 0.5;
  //theSwitch.borderColor = BLUE_COLOR;
  //theSwitch.backgroundColor = BLUE_COLOR;
  theSwitch.bounds = CGRectMake(00, 00, 20, 20);
  theSwitch.anchorPoint = CGPointMake(0.0, 0.0);
  
  //self.opacity = 0.5;
  
  theSwitch.frame = CGRectMake(0, 0, 40, 40);
  [theSwitch addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMinY relativeTo:@"superlayer" attribute:kCAConstraintMinY]]; 
  [theSwitch addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintHeight relativeTo:@"superlayer" attribute:kCAConstraintHeight]];    
  
  [self addSublayer:theSwitch];
  
  // TODO -- create image gradient
  NSBezierPath* path = [NSBezierPath bezierPathWithRoundedRect:NSRectFromCGRect(theSwitch.frame) 
                                                       xRadius:radius yRadius:radius];
  // 253 -> 230
  NSColor* gradientTop    = [NSColor colorWithCalibratedWhite:0.9921 alpha:1.0];
  NSColor* gradientBottom = [NSColor colorWithCalibratedWhite:0.8019 alpha:1.0];
  NSGradient *bgGradient = [[NSGradient alloc] initWithStartingColor:gradientBottom
                                                endingColor:gradientTop];

  

  NSImage* buttonImage = [[NSImage alloc] initWithSize:[path bounds].size];
  [buttonImage lockFocus];
  {
    [bgGradient drawInBezierPath:path angle:90.0];
  }
  [buttonImage unlockFocus];
  
  CGImageRef imageRef = [PPImageUtils createCGRefFromNSImage:buttonImage];
  [theSwitch setContents:(id)imageRef];
  CGImageRelease(imageRef);
  [buttonImage autorelease];
  
}

- (void) switchSide {
  CGRect newFrame = theSwitch.frame;
  CGFloat superWidth = CGRectGetWidth(self.frame);
  
  BOOL moveToRight = theSwitch.frame.origin.x == 0;
  if (_currentEventState == PPdragOccurred) {
    CGFloat centre = CGRectGetWidth(self.frame) / 2;
    CGFloat buttonCentre = CGRectGetWidth(theSwitch.frame) / 2 + theSwitch.frame.origin.x;
    if (buttonCentre > centre) {
      moveToRight = YES;
    } else {
      moveToRight = NO;
    }
    
  }
  
  // Slide to the right
  if (moveToRight) {
    newFrame.origin.x = superWidth - CGRectGetWidth(newFrame);
  } else {
    //Slide to the left
    newFrame.origin.x = 0;
  }
  
  
  theSwitch.frame = newFrame;  
  
  _currentEventState = PPNoEvent;  
}

- (void)moveSwitch:(CGFloat)centrePt {
  // ignore the request if we are hidden
  if (self.hidden ) return;
  
  CGRect newFrame = theSwitch.frame;
  CGFloat newX = centrePt - CGRectGetWidth(theSwitch.frame) / 2;
  CGFloat maxX = CGRectGetWidth(self.frame) - CGRectGetWidth(theSwitch.frame);
  
  if (newX < 0) {
    newX = 0;
  } 
  if (newX > maxX) {
    newX = maxX;
  }
  
  newFrame.origin.x = newX;
  
  // Slider tracking should be immediate
  [CATransaction begin];
  {
    [CATransaction setValue:[NSNumber numberWithFloat:0] forKey:kCATransactionAnimationDuration];
    theSwitch.frame = newFrame;  
  }
  [CATransaction commit];
  
}


@end
