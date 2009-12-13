//
//  Controller.h
//  CocoaMondoKit
//
//  Created by Matthieu Cormier on 12/13/09.
//  Copyright 2009 Preen and Prune Software and Design. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MondoSwitch;

@interface Controller : NSObject {

  IBOutlet MondoSwitch *mondoswitch;
  
  BOOL _on;
}

@property(nonatomic, getter=isOn) BOOL on;

- (IBAction) test:(id)sender;

@end
