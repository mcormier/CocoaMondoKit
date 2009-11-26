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

#import "MondoTextField.h"
#import "MondoTextFieldCell.h"
#import "MondoZoomWindowController.h"

#define INVISIBLE 0.0
#define VISIBLE 1.0

#define SMALL_BUTTON 19
#define MINI_BUTTON 15

@interface MondoTextField (private)
  -(void)positionButton;
  -(void)displayButtonIfNeeded;
  -(void)setupListeners;
  -(void)sendChangeNotification;
@end


@implementation MondoTextField

@synthesize windowTitle;

// The whitespace margin for text in the textfield.  
// Currently only tested with "Small" size textfields.
static NSInteger HORIZ_MARGIN = 3;
static NSInteger BUTTON_RIGHT_MARGIN = 2;

- (id)initWithCoder:(NSCoder *)decoder {
  
  if (self = [super initWithCoder:decoder] ) {    
    
    int buttonHeight = NSHeight([self frame]);
    
    // Check the size. Is it a regular, small or mini control?
    // The button must be created before the custom cell because the cell
    // needs to know the width of the button. 
    switch (buttonHeight) {
      case SMALL_BUTTON:
        zoomButton = [[MondoZoomWindowController sharedMondoZoomWindowController] getSmallButton];
        break;
      case MINI_BUTTON:
        zoomButton = [[MondoZoomWindowController sharedMondoZoomWindowController] getMiniButton];
        break;
      default:
        zoomButton = [[MondoZoomWindowController sharedMondoZoomWindowController] getRegularButton];
        break;
    }
    
    [zoomButton setFocusRingType:NSFocusRingTypeNone];
    [self positionButton];
    [self addSubview:zoomButton];
    
    // Add +1 for margin
    MondoTextFieldCell *mondoCell = [[MondoTextFieldCell alloc] initWithButtonWidth:[[zoomButton image] size].width + 1 andCell:[self cell]];
    [self setDelegate:mondoCell];
    [self setCell:mondoCell];
    [mondoCell release];
    
    

  }
  return self;
}

- (void)awakeFromNib {
  _attrDict = [[NSDictionary dictionaryWithObject: [self font] forKey:NSFontAttributeName] retain];
  
  // We don't want any animation on startup
  // Prevents the button from being displayed for a split second
  // and fading out.
  [[NSAnimationContext currentContext] setDuration:0.0];
  [self displayButtonIfNeeded];
  
  // We will be fading the button in and out so
  // the appearance of the button is not abrupt to the user.
  zoomButton.wantsLayer = YES;

  [self setupListeners];
}


-(void)setupListeners {
  [[NSNotificationCenter defaultCenter]
   addObserver:self
   selector:@selector(windowBecameOrResignedKey:)
   name:NSWindowDidBecomeKeyNotification object:[self window]];
  
  [[NSNotificationCenter defaultCenter]
   addObserver:self
   selector:@selector(windowBecameOrResignedKey:)
   name:NSWindowDidResignKeyNotification object:[self window]];
  
  [zoomButton setTarget: self];
  [zoomButton setAction: @selector(zoomButtonPressed:)];

}

- (void) zoomButtonPressed: (id) sender {
  
  // The button is invisible so act like it doesn't exist.  
  if ( [zoomButton alphaValue] == INVISIBLE ) {
    NSRange selectLastPosition;
    selectLastPosition.length = 0;    
    selectLastPosition.location = [[self stringValue] length];   
    
    [[self window] makeFirstResponder:self];
    NSText *fieldEditor = [[self window] fieldEditor:YES forObject:self];
    [fieldEditor setSelectedRange:selectLastPosition];
    return;
  }
  
  // Make sure this textfield is the first responder since the user clicked
  // the button.  This fixes a UI bug where the first responder flickers
  // if you switch from one MondoTextField to another using the buttons only.
  // We must also save the current selection before setting itself self
  // to first responder or else all text will be selected.
  NSText *mondoFieldEditor = [[self window] fieldEditor:YES forObject:self];
  NSRange mondoSelection = [mondoFieldEditor selectedRange];      
  [[self window] makeFirstResponder:self];
  [mondoFieldEditor setSelectedRange:mondoSelection];
  
  
  [[MondoZoomWindowController sharedMondoZoomWindowController] showWindow:self]; 
  
}

- (void)dealloc {
	[_attrDict release];
	[super dealloc];

}

- (void)setFrame:(NSRect)frameRect {
  [super setFrame:frameRect];
  [self positionButton];
  [self displayButtonIfNeeded];
}

- (void)positionButton {
  NSRect myFrame = [self frame];
  NSSize buttonSize = [[zoomButton image] size];
  [zoomButton setFrame:NSMakeRect( NSWidth(myFrame) - (buttonSize.width + BUTTON_RIGHT_MARGIN) , 1, buttonSize.width, buttonSize.height)];
}

- (void)windowBecameOrResignedKey:(NSNotification *)aNotification {
     // Forces the focus ring to be drawn correctly
		[[self window] display];
}

- (void)setStringValue:(NSString *)aString {
  //[super setStringValue:aString];
  [super setStringValue:@"blah"];
  [self sendChangeNotification];
}


- (void)textDidChange:(NSNotification *)aNotification {
  [self sendChangeNotification];
}

-(void)sendChangeNotification {
  [self displayButtonIfNeeded];
  // Let any listeners know that the text changed.  
  [[NSNotificationCenter defaultCenter] 
   postNotificationName:@"NSControlTextDidChangeNotification" object:self];  
}

- (float) stringWidth {
  NSString *str = [self stringValue];
  return [str sizeWithAttributes:_attrDict].width;  
}

-(void)displayButtonIfNeeded {
  // The cell is inset from TextField frame so we add 1 plus 2 for the margin on the right.  Otherwise the button
  // appears one character too late.
  float textViewportWidth = NSWidth([self frame]) - ([[zoomButton image] size].width + HORIZ_MARGIN * 2);
  BOOL buttonVisible = [self stringWidth] > textViewportWidth;
  
  [[zoomButton animator] setAlphaValue: (buttonVisible ? VISIBLE : INVISIBLE)];
}

-(void)setWindowTitle:(NSString *)title {
  NSLog(@"Setting title --> %@", title);
  [title retain];
  [windowTitle release];
  windowTitle = title;
}

- (NSString*) fieldLabel {
  return windowTitle;
}

@end

