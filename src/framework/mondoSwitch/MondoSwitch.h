//
//  MondoSwitch.h
//  CocoaMondoKit
//
//  Created by Matthieu Cormier on 12/7/09.
//  Copyright 2009 Preen and Prune Software and Design. All rights reserved.
//

#import <Cocoa/Cocoa.h>


// UISwitch reference
// http://developer.apple.com/iphone/library/documentation/UIKit/Reference/UISwitch_Class/Reference/Reference.html

// Checkbox is an instance of NSButton
// http://developer.apple.com/mac/library/documentation/cocoa/reference/ApplicationKit/Classes/NSButton_Class/Reference/Reference.html
//
@class MondoSwitchButtonCALayer;

@interface MondoSwitch : NSControl {

@private
  NSGradient *bgGradient;
  MondoSwitchButtonCALayer *buttonLayer;
}

@end
