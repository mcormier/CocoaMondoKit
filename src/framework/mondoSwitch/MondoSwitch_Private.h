/*
 *  MondoSwitch_Private.h
 *  CocoaMondoKit
 *
 *  Created by Matthieu Cormier on 12/11/09.
 *  Copyright 2009 Preen and Prune Software and Design. All rights reserved.
 *
 */

@interface MondoSwitch (PrivateMethods)
-(void)setupLayers;
-(CGPoint) pointForEvent:(NSEvent *) event;
-(void)coreAnimationDrawRect:(NSRect)dirtyRect;
-(BOOL)isRunningInIB;

-(NSGradient*)gradient;
-(void)setGradient:(NSGradient*)gradient;

@end
