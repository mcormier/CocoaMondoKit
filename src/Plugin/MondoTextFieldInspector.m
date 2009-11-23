//
//  MondoTextFieldInspector.m
//  CocoaMondoKit
//
//  Created by Matthieu Cormier on 11/22/09.
//  Copyright 2009 Allusions Software. All rights reserved.
//

#import "MondoTextFieldInspector.h"


@implementation MondoTextFieldInspector

- (NSString *)viewNibName {
	return @"MondoTextFieldInspector";
}

- (void)refresh {
	// Synchronize your inspector's content view with the currently selected objects.
	[super refresh];
}


@end
