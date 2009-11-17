//
//  CocoaMondoKit.m
//  CocoaMondoKit
//
//  Created by Matthieu Cormier on 11/12/09.
//  Copyright 2009 Allusions Software. All rights reserved.
//

#import "CocoaMondoKit.h"

@implementation CocoaMondoKit
- (NSArray *)libraryNibNames {
    return [NSArray arrayWithObject:@"CocoaMondoKitLibrary"];
}

- (NSArray *)requiredFrameworks {
    return [NSArray arrayWithObjects:[NSBundle bundleWithIdentifier:@"com.preenandprune.CocoaMondoKit"], nil];
}

@end
