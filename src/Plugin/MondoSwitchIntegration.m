
#import <InterfaceBuilderKit/InterfaceBuilderKit.h>
#import "MondoSwitch.h"
#import "MondoSwitch_Private.h"

@class IBApplication;

@interface MondoSwitch (MondoSwitchIntegration)
-(BOOL)isRunningInIB;
@end


@implementation MondoSwitch ( MondoSwitchIntegration) 

-(BOOL)isRunningInIB {
  NSString *appName = NSStringFromClass([[NSApplication sharedApplication] class]);
  return [appName caseInsensitiveCompare:@"IBApplication"] == NSOrderedSame;  
  
}


// Override awakeFromNib.  This fixes a dragging bug
// by turning off core data when in Interface Builder.
- (void)awakeFromNib { 
  if (![self isRunningInIB]) {
    [self setupLayers];
  }
}

// Override drawing behaviour in Interface builder.
// Interface builder doesn't seem to work well with Core Animation layers
// So draw a simple switch using an image.
- (void)drawRect:(NSRect)dirtyRect {
  
  // For the case when we are in Interface Builder
  // but the Cocoa Simulator is being used.
  if (![self isRunningInIB]) {
    [self coreAnimationDrawRect:dirtyRect];
    return;
  }
  
  Class mondoKitClazz = NSClassFromString(@"CocoaMondoKit");
  NSBundle *otherBundle = [NSBundle bundleForClass:mondoKitClazz];
  NSImage *image = [[NSImage alloc] initWithContentsOfFile:[otherBundle pathForImageResource:@"MondoSwitchIBDisplay.png"]];

  [image drawInRect:dirtyRect fromRect:NSZeroRect            
         operation:NSCompositeSourceOver fraction:1.0]; 
  [image release];
}


@end