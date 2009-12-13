/*
 *  PPCommon.h
 *  CocoaMondoKit
 *
 *  Created by Matthieu Cormier on 12/8/09.
 *  Copyright 2009 Preen and Prune Software and Design. All rights reserved.
 *
 */

#define PPAssign(oldValue,newValue) \
[ newValue retain ]; \
[ oldValue release ]; \
oldValue = newValue;

#define PPRelease(value) \
if ( value ) { \
[value release]; \
value = nil; \
}

#define PPConstraint(attr, rel) \
[CAConstraint constraintWithAttribute:attr relativeTo:rel attribute:attr]


@interface PPImageUtils : NSObject {
  
}

// The caller is responsible for calling CGImageRelease on the returned value
+ (CGImageRef)createCGRefFromNSImage:(NSImage*)image;

+ (NSImage*)cropImage:(NSImage*)sourceImage withRect:(NSRect)sourceRect;


@end
