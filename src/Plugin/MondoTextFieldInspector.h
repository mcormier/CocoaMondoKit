//
//  MondoTextFieldInspector.h
//  CocoaMondoKit
//
//  Created by Matthieu Cormier on 11/22/09.
//  Copyright 2009 Allusions Software. All rights reserved.
//

#import <InterfaceBuilderKit/InterfaceBuilderKit.h>
#import "MondoTextField.h"

@interface MondoTextFieldInspector : IBInspector {
  MondoTextField *textField;
  
  NSString* windowTitle;
}

@property(retain) NSString* windowTitle;

@end
