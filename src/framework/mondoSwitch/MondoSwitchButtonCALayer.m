//
//  MondoSwitchButtonCALayer.m
//  CocoaMondoKit
//
//  Created by Matthieu Cormier on 12/8/09.
//  Copyright 2009 Preen and Prune Software and Design. All rights reserved.
//

#import "MondoSwitchButtonCALayer.h"
#import "MondoSwitchButtonCALayer_Private.h"
#import "PPCommon.h"

@implementation MondoSwitchButtonCALayer

@synthesize on=_on;

#pragma mark -
#pragma mark init methods

- (id) init {
  [super init];
  self.autoresizingMask = kCALayerWidthSizable;
  self.cornerRadius = 5.0;
  self.masksToBounds = YES;
  self.borderWidth = 0;
  self.bounds = CGRectMake(00, 00, 20, 20);
  self.anchorPoint = CGPointMake(0.0, 0.0);

  [self addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMinY relativeTo:@"superlayer" attribute:kCAConstraintMinY]];
  [self addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMinX relativeTo:@"superlayer" attribute:kCAConstraintMinX]];
  
	[self addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintWidth relativeTo:@"superlayer" attribute:kCAConstraintWidth]];  
  [self addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintHeight relativeTo:@"superlayer" attribute:kCAConstraintHeight]];  
  [self setLayoutManager:[CAConstraintLayoutManager layoutManager]];
  
  [self createtheSwitch];
  _currentEventState = PPNoEvent;
  
  return self;
}

- (void) dealloc {
  CGImageRelease(notClickedImgRef);
  CGImageRelease(clickedImgRef);
  [super dealloc];
}



#pragma mark -
#pragma mark mouse events

-(void)mouseDown:(CGPoint)point {
  _currentEventState = CGRectContainsPoint ( theSwitch.frame, point )  
                       ? PPcanDragSwitch : PPstandardMouseDown;

  if (_currentEventState == PPcanDragSwitch) {
    [theSwitch setContents:(id)clickedImgRef];
  }
}

-(void)mouseUp:(CGPoint)point {
    [self switchSide];
    [theSwitch setContents:(id)notClickedImgRef];
}


-(void)mouseDragged:(CGPoint)point {
  
  if (_currentEventState == PPdragOccurred ||  _currentEventState == PPcanDragSwitch) {
    _currentEventState = PPdragOccurred;
    [self moveSwitch:point.x];   
  }
  
}

#pragma mark -
#pragma mark propertyMethods
-(void)setOn:(BOOL)on {
  if (_on == on ) { return; }
  [self switchSide];
}

- (void)setOn:(BOOL)on animated:(BOOL)animated {
  if (!animated) {
    [CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithFloat:0] forKey:kCATransactionAnimationDuration];
  }
  [self switchSide];    
  if (!animated) {
    [CATransaction commit];
  }  
}

@end

#pragma mark -
@implementation MondoSwitchButtonCALayer (PrivateMethods)

- (void) createtheSwitch {
  theSwitch = [CALayer layer];
  [theSwitch retain];
  
  CGFloat radius = 5.0;
  
  theSwitch.cornerRadius = radius;
  theSwitch.masksToBounds = YES;
  theSwitch.borderWidth = 0.5;
  theSwitch.bounds = CGRectMake(00, 00, 20, 20);
  theSwitch.anchorPoint = CGPointMake(0.0, 0.0);

  NSLog(@"This shouldn't be hard coded.");
  theSwitch.frame = CGRectMake(0, 0, 40, 40);
  [theSwitch addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMinY relativeTo:@"superlayer" attribute:kCAConstraintMinY]]; 
  [theSwitch addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintHeight relativeTo:@"superlayer" attribute:kCAConstraintHeight]];    
  
  [self addSublayer:theSwitch];
  
  NSBezierPath* path = [NSBezierPath bezierPathWithRoundedRect:NSRectFromCGRect(theSwitch.frame) 
                                                       xRadius:radius yRadius:radius];
  
  // TODO -- magic numbers...
  notClickedImgRef = [self switchImageForPath:path topColor:0.9921 bottomColor:0.9019];
  clickedImgRef = [self switchImageForPath:path topColor:0.8745 bottomColor:0.9568];
  
  [theSwitch setContents:(id)notClickedImgRef];
  
}

- (void) switchSide {
  CGRect newFrame = theSwitch.frame;
  CGFloat superWidth = CGRectGetWidth(self.frame);
    
  if (_currentEventState == PPdragOccurred) {
    CGFloat centre = CGRectGetWidth(self.frame) / 2;
    CGFloat buttonCentre = CGRectGetWidth(theSwitch.frame) / 2 + theSwitch.frame.origin.x;
    self.on = buttonCentre > centre ? YES : NO;
  } else {
    self.on = theSwitch.frame.origin.x == 0;
  }
    
  newFrame.origin.x = self.on ? superWidth - CGRectGetWidth(newFrame) : 0;
  
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

- (CGImageRef)switchImageForPath:(NSBezierPath*)path topColor:(CGFloat)topColor  bottomColor:(CGFloat)bottomColor {  
  
  NSColor* gradientTop    = [NSColor colorWithCalibratedWhite:topColor alpha:1.0];
  NSColor* gradientBottom = [NSColor colorWithCalibratedWhite:bottomColor alpha:1.0];
  NSGradient *bgGradient = [[NSGradient alloc] initWithStartingColor:gradientBottom
                                                         endingColor:gradientTop];

  NSImage* buttonImage = [[NSImage alloc] initWithSize:[path bounds].size];
  [buttonImage lockFocus];
  {
    [bgGradient drawInBezierPath:path angle:90.0];
  }
  [buttonImage unlockFocus];
  
  CGImageRef imgRef = [PPImageUtils createCGRefFromNSImage:buttonImage];
  [buttonImage release];
  [bgGradient release];
  
  return imgRef;  
}


@end
