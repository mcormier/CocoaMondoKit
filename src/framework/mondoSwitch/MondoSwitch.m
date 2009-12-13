//
//  MondoSwitch.m
//  CocoaMondoKit
//
//  Created by Matthieu Cormier on 12/7/09.
//  Copyright 2009 Preen and Prune Software and Design. All rights reserved.
//

#import "MondoSwitch.h"
#import "MondoSwitch_Private.h"
#import "MondoSwitchButtonCALayer.h"
#import "PPCommon.h"

@implementation MondoSwitch

@synthesize on=_on;

#pragma mark -
#pragma mark init methods

- (void)awakeFromNib {    
  // draw a basic gradient for the view background
  NSColor* gradientBottom = [NSColor colorWithCalibratedWhite:0.72 alpha:1.0];
  NSColor* gradientTop    = [NSColor colorWithCalibratedWhite:0.46 alpha:1.0];
  
	bgGradient = [[NSGradient alloc] initWithStartingColor:gradientBottom
                                             endingColor:gradientTop];
  
  [self setupLayers];
  
  [self bind:@"on" toObject:buttonLayer withKeyPath:@"on" options:nil];
}  

-(void)setupLayers {
   
  // create a layer and match its frame to the view's frame
  self.wantsLayer = YES;

  CALayer* mainLayer = self.layer;
  mainLayer.name = @"mainLayer";

  CGRect viewFrame = NSRectToCGRect( self.frame );
  viewFrame.origin.y = 0;
  viewFrame.origin.x = 0;  
  mainLayer.frame = viewFrame;

  mainLayer.delegate = self;
  
  // causes the layer content to be drawn in -drawRect:
  [mainLayer setNeedsDisplay];
  
  CGFloat midX = CGRectGetMidX( mainLayer.frame );
  CGFloat midY = CGRectGetMidY( mainLayer.frame );

  
  // create a "container" layer for all content layers.
  // same frame as the view's master layer, automatically
  // resizes as necessary.    
  CALayer* contentContainer = [CALayer layer];    
  contentContainer.bounds           = mainLayer.bounds;
  contentContainer.delegate         = self;
  contentContainer.anchorPoint      = CGPointMake(0.5,0.5);
  contentContainer.position         = CGPointMake( midX, midY );
  contentContainer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
  [contentContainer setLayoutManager:[CAConstraintLayoutManager layoutManager]];    
  [self.layer addSublayer:contentContainer];
  
  buttonLayer = [MondoSwitchButtonCALayer layer];
  buttonLayer.name = @"switchLayer";
  
  [contentContainer addSublayer:buttonLayer];
  
  [contentContainer layoutSublayers];
  [contentContainer layoutIfNeeded]; 
}

- (void) dealloc {
  PPRelease(bgGradient);
  [super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect {
  // Everything else is handled by core animation
  CGFloat radius = 5.0;
  NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:dirtyRect
                                                       xRadius:radius
                                                       yRadius:radius];

  [bgGradient drawInBezierPath:path angle:90.0];
  
  NSColor* borderColor = [NSColor colorWithCalibratedWhite:0.27 alpha:1.0];
  [borderColor set];
  [path stroke];
  
}

#pragma mark -
#pragma mark propertyMethods

-(void)setOn:(BOOL)on {
  if (_on == on) { return; }
  _on = on;
  [buttonLayer setOn:on];
}

-(void)setOn:(BOOL)on animated:(BOOL)animated {
  if (_on == on) { return; }
  _on = on;
  [buttonLayer setOn:on animated:animated];
}

#pragma mark -
#pragma mark mouse methods

- (void) mouseDown: (NSEvent *) event {
  
  // ignore double clicks
  if ([event clickCount] > 1 ) { return; }
  
  CGPoint location = [self pointForEvent:event];
  [buttonLayer mouseDown:location];
}

- (void)mouseUp:(NSEvent *)event {
  // ignore double clicks
  if ([event clickCount] > 1 ) { return; }
  
  CGPoint location = [self pointForEvent:event];
  [buttonLayer mouseUp:location];
}

- (void)mouseDragged:(NSEvent *)event {
  CGPoint location = [self pointForEvent:event];
  [buttonLayer mouseDragged:location];
}

- (CGPoint) pointForEvent:(NSEvent *) event {
  NSPoint location = [self convertPoint:[event locationInWindow] fromView:nil];
  return NSPointToCGPoint(location);
}


@end
