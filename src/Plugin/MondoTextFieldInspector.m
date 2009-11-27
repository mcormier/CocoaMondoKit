//
//  MondoTextFieldInspector.m
//  CocoaMondoKit
//
//  Created by Matthieu Cormier on 11/22/09.
//  Copyright 2009 Allusions Software. All rights reserved.
//

#import "MondoTextFieldInspector.h"


@implementation MondoTextFieldInspector

@synthesize windowTitle;

- (NSString *)viewNibName {
	return @"MondoTextFieldInspector";
}

- (void)refresh {
	// Synchronize your inspector's content view with the currently selected objects.
	[super refresh];
  
  textField = [[self inspectedObjects] objectAtIndex:0];
  [self setWindowTitle:[textField windowTitle]];
  
}


+ (BOOL)supportsMultipleObjectInspection
{
	return NO;
}

-(void)setWindowTitle:(NSString *)title {
  [title retain];
  [windowTitle release];
  windowTitle = title;
  
  [textField setWindowTitle:windowTitle];
}

@end
