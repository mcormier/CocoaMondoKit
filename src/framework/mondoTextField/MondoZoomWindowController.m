//  Created by Matthieu Cormier on Mon December 8 2008.
//
//  Copyright (c) 2008 Matthieu Cormier. All rights reserved.
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided 
//  that the following conditions are met:
//
//    * Redistributions of source code must retain the above copyright notice, this list of conditions and the 
//      following disclaimer.
//    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and 
//      the following disclaimer in the documentation and/or other materials provided with the distribution.
//    * Neither the name of Matthieu Cormier nor the names of its contributors may be used to endorse or promote 
//      products derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, 
//  INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
//  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
//  WHETHER IN CONTRACT,  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE 
//  USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "MondoZoomWindowController.h"
#import "MondoTextField.h"
#import "SynthesizeSingleton.h"
#import "NSWindow-NoodleEffects.h"

#define INVISIBLE 0.0

@interface MondoZoomWindowController (Private)
-(NSButton*)makeButtonWithImageName:(NSString*)imgName andAltImage:(NSString*)altImgName;
-(void)transferSelection:(MondoTextField*)fromField to:(NSTextField*)toField;
-(NSRect)getMinimizeRect;  
-(void)setBestWindowSize;
-(void)closeFocusWindow;

// Don't use property/synthesize.  We want these methods to be private.
-(MondoTextField*)currentMondoField;
-(void)setCurrentMondoField:(MondoTextField*)newCurrentField;
@end



@implementation MondoZoomWindowController

SYNTHESIZE_SINGLETON_FOR_CLASS(MondoZoomWindowController);

- (id) init {
  if ( self = [super init] ) {          
    if (![NSBundle loadNibNamed:@"mondoZoomPanel" owner:self]) {
      NSLog(@"Error loading mondoZoomPanel Nib for document! Gah");
    } 
    
  }
  
  return self;  
} 

- (void) awakeFromNib {
  _attrDict = [[NSDictionary dictionaryWithObject: [zoomTextField font] forKey:NSFontAttributeName] retain];
  
  // It's better to set the delegate in code instead of interface builder
  // because we wan't to ignore the first resize message when the nib is loaded
  // and the window is changed.  User resizes will be restricted to width only
  // after that.
  [zoomPanel setDelegate:self];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) 
                                               name:@"NSControlTextDidChangeNotification" object:zoomTextField ];

}

- (void)dealloc {
  self.currentMondoField = nil;
	[_attrDict release];
	[super dealloc];
}



- (void)showWindow:(MondoTextField*)mondoField  {

  self.currentMondoField = mondoField; 
  NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
  [nc addObserver:self selector:@selector(textChanged:) 		
             name:@"NSControlTextDidChangeNotification" object:self.currentMondoField ];
  [nc addObserver:self selector:@selector(parentWindowClosed:) 			
             name:@"NSWindowWillCloseNotification" object:[self.currentMondoField window] ];

  
  [zoomTextField setStringValue:[mondoField stringValue]];  
  [zoomPanel setTitle:[mondoField fieldLabel]];
  
  [self transferSelection:self.currentMondoField to:zoomTextField];
  
  // Don't animate if the window is already visible  
  if ([zoomPanel isVisible]) {
    [zoomPanel makeKeyAndOrderFront:self];    
    return;
  }
  
   
  [self setBestWindowSize];
    
  [zoomPanel zoomOnFromRect:[self getMinimizeRect]];
  
  return;
  
}


- (NSButton*)getRegularButton {
  return [self makeButtonWithImageName:@"zoomFieldRegular.png" andAltImage:@"zoomFieldRegular_Pressed.png"];
}

- (NSButton*)getSmallButton {
  return [self makeButtonWithImageName:@"zoomFieldSmall.png" andAltImage:@"zoomFieldSmall_Pressed.png"];
}

- (NSButton*)getMiniButton {
  return [self makeButtonWithImageName:@"zoomFieldMini.png" andAltImage:@"zoomFieldMini_Pressed.png"];
}

#pragma mark Notifications
- (void)textChanged:(NSNotification*)sender {
  
  if ([sender object] == zoomTextField) {
    [self.currentMondoField  setStringValue:[zoomTextField stringValue]];
  } 
  
  if ([sender object] == self.currentMondoField) {
    [zoomTextField setStringValue:[self.currentMondoField stringValue]];
  }
  
}

- (void)parentWindowClosed:(NSNotification*)sender {
  [self closeFocusWindow];
}



#pragma mark NSWindow delegate methods

- (BOOL)windowShouldClose:(id)window {  
   [zoomPanel zoomOffToRect:[self getMinimizeRect]];
  
  // We will close the window when the animation is finished
  return NO;
 }

// User resizes are restricted to width only.
- (NSSize)windowWillResize:(NSWindow *)window toSize:(NSSize)proposedFrameSize {
  NSSize noHeightResize;
  noHeightResize.height = NSHeight([window frame]);
  noHeightResize.width = proposedFrameSize.width;
  return noHeightResize;
}


@end

@implementation MondoZoomWindowController (Private)

- (void)setBestWindowSize {  
  NSRect windowFrame = [zoomPanel frame];
  windowFrame.size.width += [self.currentMondoField stringWidth] - NSWidth([zoomTextField frame]);
  windowFrame.size.width += 100;  // Make the text field slightly larger than the entire text
  
  // Consider the minimize size for the window set in the XIB
  NSSize minSize = [zoomPanel minSize];
  if ( windowFrame.size.width < minSize.width) {
    windowFrame.size.width = minSize.width;
  }
  
  // Make sure the width is no wider than the width of the screen that contains the window origin  
  
  // Window resizing should make sure it's not out of bounds of screen.
  for( NSScreen* screen in [NSScreen screens] ) {           
    // We've found the screen with the origin of our window   
    if(NSPointInRect(windowFrame.origin, [screen frame]) ) {
      // If the width of the window is greater than this screen then limit
      // the width to the width of this screen.  
      if (windowFrame.size.width > [screen frame].size.width ) {
        windowFrame.size.width = [screen frame].size.width; }
    }
  }
    
  [zoomPanel setFrame:windowFrame display:NO ];
}



- (NSRect)getMinimizeRect {
  NSRect minimizeRect;
  minimizeRect.size.width = NSWidth([_currentMondoField frame]);
  minimizeRect.size.height = NSHeight([_currentMondoField frame]);
  minimizeRect.origin = [[_currentMondoField window] frame].origin;
  minimizeRect.origin.x += [_currentMondoField frame].origin.x;
  minimizeRect.origin.y += [_currentMondoField frame].origin.y;
  return minimizeRect;
}


// From ** Text System Overview  ** 
// - Text Fields, Text Views, and the Field Editor
//
// "The field editor is a single NSTextView object that is shared among
// all the controls, including text fields, in a window."
//
// 1. Get the fieldEditor (NSText) from the MondoTextField's window.
// 2. Check to see if the MondoTextField is the current delegate of
//    the fieldEditor
// 3. Transfer the selection if the MondoTextField is the current delegate.
//
- (void)transferSelection:(MondoTextField*)fromField to:(NSTextField*)toField {
      
  NSWindow *window = [fromField window];
  NSText *fieldEditor = [window fieldEditor:YES forObject:nil];    
  BOOL fromFieldSelected = [fieldEditor delegate] == fromField;
    
  NSText *mondoFieldEditor = [window fieldEditor:YES forObject:fromField];

  NSRange mondoSelection = [mondoFieldEditor selectedRange]; 
  [[fromField window] makeFirstResponder:fromField];
  
  // Another text field was selected and the button
  // was pushed.  Do not transfer the selection to 
  // new field.
  if (!fromFieldSelected) {
    mondoSelection.length = 0;
    mondoSelection.location = 0;
  }
  [mondoFieldEditor setSelectedRange:mondoSelection];
  
  [[toField window] makeFirstResponder:toField];
  NSText *zoomFieldEditor = [[toField window] fieldEditor:YES forObject:toField];
  [zoomFieldEditor setSelectedRange:mondoSelection];  
  
}

- (NSButton*)makeButtonWithImageName:(NSString*)imgName andAltImage:(NSString*)altImgName {
  NSBundle *bundle = [NSBundle bundleForClass:[self class]];
  NSImage *image = [[NSImage alloc] initWithContentsOfFile:[bundle pathForImageResource:imgName]];
  
  NSButton *button = [[NSButton alloc] initWithFrame:NSMakeRect(0, 0, [image size].width, [image size].height)];
  [button setBordered:NO];
  [button setImage:image];
  [image release];
  image = [[NSImage alloc] initWithContentsOfFile:[bundle pathForImageResource:altImgName]];
  [button setAlternateImage: image];
  [image release];
  [[button cell] setHighlightsBy:NSContentsCellMask];
  [button setAlphaValue:INVISIBLE];
  
  [button autorelease];
  return button;  
}

-(void)closeFocusWindow {
  [zoomPanel close];
  NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
  [nc removeObserver:self name:@"NSControlTextDidChangeNotification"                   
              object:self.currentMondoField ];    
  [nc removeObserver:self name:@"NSWindowWillCloseNotification"                   
              object:[self.currentMondoField window] ];    
}

-(MondoTextField*)currentMondoField {
  return _currentMondoField;
}

-(void)setCurrentMondoField:(MondoTextField*)newCurrentField {
  if (newCurrentField == _currentMondoField) { return; }
  
  [newCurrentField retain];
  [_currentMondoField release];
  _currentMondoField = newCurrentField;
  
}

@end
