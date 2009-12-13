//
//  Controller.m
//  CocoaMondoKit
//
//  Created by Matthieu Cormier on 12/13/09.
//  Copyright 2009 Preen and Prune Software and Design. All rights reserved.
//

#import "Controller.h"
#import "MondoSwitch.h"

@implementation Controller

@synthesize on=_on;

-(void)awakeFromNib {
  [self bind:@"on" toObject:mondoswitch withKeyPath:@"on" options:nil];
}

- (IBAction) test:(id)sender {  
  [mondoswitch setOn:![mondoswitch isOn] ];
}

- (void)setOn:(BOOL)on {
  if(_on == on) return;
  _on = on;
  
}

@end
