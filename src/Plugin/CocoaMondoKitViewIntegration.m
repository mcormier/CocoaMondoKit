//
//  CocoaMondoKitView.m
//  CocoaMondoKit
//
//  Created by Matthieu Cormier on 11/12/09.
//  Copyright 2009 Allusions Software. All rights reserved.
//

#import <InterfaceBuilderKit/InterfaceBuilderKit.h>
#import <CocoaMondoKit/CocoaMondoKitView.h>
#import "CocoaMondoKitInspector.h"


@implementation CocoaMondoKitView ( CocoaMondoKitView )

- (void)ibPopulateKeyPaths:(NSMutableDictionary *)keyPaths {
    [super ibPopulateKeyPaths:keyPaths];
	
	// Remove the comments and replace "MyFirstProperty" and "MySecondProperty" 
	// in the following line with a list of your view's KVC-compliant properties.
    [[keyPaths objectForKey:IBAttributeKeyPaths] addObjectsFromArray:[NSArray arrayWithObjects:/* @"MyFirstProperty", @"MySecondProperty",*/ nil]];
}

- (void)ibPopulateAttributeInspectorClasses:(NSMutableArray *)classes {
    [super ibPopulateAttributeInspectorClasses:classes];
    [classes addObject:[CocoaMondoKitInspector class]];
}

@end
