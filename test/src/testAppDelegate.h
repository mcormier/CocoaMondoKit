//
//  testAppDelegate.h
//  test
//
//  Created by Matthieu Cormier on 11/17/09.
//  Copyright 2009 Allusions Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface testAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end
