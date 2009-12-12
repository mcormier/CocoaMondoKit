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

@class MondoSwitchButtonCALayer;

@interface MondoSwitch : NSControl {

  @private
    NSGradient *bgGradient;
    MondoSwitchButtonCALayer *buttonLayer;
    BOOL on;
}

@property(nonatomic, getter=isOn) BOOL on;

-(void)setOn:(BOOL)on animated:(BOOL)animated;
@end
