//
//  CocoaMondoKitInspector.m
//  CocoaMondoKit
//
//  Created by Matthieu Cormier on 11/12/09.
//  Copyright 2009 Allusions Software. All rights reserved.
//

#import "CocoaMondoKitInspector.h"

@implementation CocoaMondoKitInspector

- (NSString *)viewNibName {
	return @"CocoaMondoKitInspector";
}

- (void)refresh {
	// Synchronize your inspector's content view with the currently selected objects.
	[super refresh];
}

@end
