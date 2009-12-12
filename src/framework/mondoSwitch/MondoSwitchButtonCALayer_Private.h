/*
 *  MondoSwitchButtonCALayer_Private.h
 *  CocoaMondoKit
 *
 *  Created by Matthieu Cormier on 12/11/09.
 *  Copyright 2009 Preen and Prune Software and Design. All rights reserved.
 *
 */

@interface MondoSwitchButtonCALayer (PrivateMethods)
- (void)createtheSwitch;
- (void)switchSide;
- (void)moveSwitch:(CGFloat)dx;
- (CGImageRef)switchImageForPath:(NSBezierPath*)path topColor:(CGFloat)topColor  bottomColor:(CGFloat)bottomColor;
@end
