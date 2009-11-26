//
//  MondoTextFieldIntegration.m
//  CocoaMondoKit
//
//  Created by Matthieu Cormier on 11/22/09.
//  Copyright 2009 Allusions Software. All rights reserved.
//

#import <InterfaceBuilderKit/InterfaceBuilderKit.h>
#import "MondoTextField.h"
#import "MondoTextFieldInspector.h"

@implementation MondoTextField ( MondoTextFieldIntegration )

- (void)ibPopulateKeyPaths:(NSMutableDictionary *)keyPaths {
 
  [super ibPopulateKeyPaths:keyPaths];
  
  [[keyPaths objectForKey:IBAttributeKeyPaths] addObjectsFromArray:
        [NSArray arrayWithObjects:@"windowTitle", nil]];
}

- (void)ibPopulateAttributeInspectorClasses:(NSMutableArray *)classes {
  [super ibPopulateAttributeInspectorClasses:classes];
  [classes addObject:[MondoTextFieldInspector class]];
}


@end
