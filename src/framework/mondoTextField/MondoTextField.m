//  Copyright (c) MMIX Matthieu Cormier. All rights reserved.
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

#define SMALL_TEXTFIELD 19

// Textfields created in interface builder with a size of mini on Leopard
// had a height of 15 pixels.
// Textfields created in interface builder with a size of mini on Snow
// Leopard have a height of 16 pixels.
#define MINI_TEXTFIELD_LEOPARD 15       // OS X 10.5
#define MINI_TEXTFIELD_SNOW_LEOPARD 16  // OS X 10.6

@interface MondoTextField (private)
  -(void)positionButton:(NSRect)forFrame;
  -(void)displayButtonIfNeeded;
  -(void)setupListeners;
  -(void)sendChangeNotification;
  -(NSButton*)createButtonForControlHeight;
  -(void)createMondoTextFieldCell;

  // The zoom button should always be accessed from this method.
  // The MondoTextField only has one subview so it grabs that view.
  // If the button isn't present then it creates it.
  -(NSButton*)zoomButton;
  - (float) stringWidth;
@end


@implementation MondoTextField

@synthesize windowTitle;

// The whitespace margin for text in the textfield.  
// Currently only tested with "Small" size textfields.
static NSInteger HORIZ_MARGIN = 3;
static NSInteger BUTTON_RIGHT_MARGIN = 2;

- (id)initWithCoder:(NSCoder *)decoder {
  if (self = [super initWithCoder:decoder] ) {    
    [self setWindowTitle:[decoder decodeObjectForKey:@"MondoWindowTitle"]];
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
  [super encodeWithCoder:coder];
  [coder encodeObject:[self windowTitle] forKey:@"MondoWindowTitle"];
}

- (void)createMondoTextFieldCell {
  MondoTextFieldCell *mondoCell = [[MondoTextFieldCell alloc] initWithCell:[self cell]];
  
  [self setDelegate:mondoCell];
  [self setCell:mondoCell];
  [mondoCell release];  
}

-(NSButton*)zoomButton {
  NSButton* zoomButton;
  
  @try {
    zoomButton = [[self subviews] objectAtIndex:0];
  } 
  @catch (NSException *e) {
    if ( [[e name] caseInsensitiveCompare:NSRangeException] == NSOrderedSame) {
      zoomButton = [self createButtonForControlHeight];
    } else{
      NSLog(@"Unexpected error...");
    }
    
  }
  return zoomButton;
}

-(NSButton*)createButtonForControlHeight {
  int buttonHeight = NSHeight([self frame]);
  
  NSButton *zoomButton;
  // Check the size. Is it a regular, small or mini control?
  // The button must be created before the custom cell because the cell
  // needs to know the width of the button. 
  switch (buttonHeight) {
    case MINI_TEXTFIELD_LEOPARD:
    case MINI_TEXTFIELD_SNOW_LEOPARD:
    case SMALL_TEXTFIELD:
      zoomButton = [[MondoZoomWindowController sharedMondoZoomWindowController] getMiniButton];
      break;
    default:
      zoomButton = [[MondoZoomWindowController sharedMondoZoomWindowController] getRegularButton];
      break;
  }
  
  // We will be fading the button in and out so
  // the appearance of the button is not abrupt to the user.
  zoomButton.wantsLayer = YES;  
  [zoomButton setFocusRingType:NSFocusRingTypeNone];
  [self setSubviews:[NSArray arrayWithObject:zoomButton]];
    
  [self positionButton:[self frame]];
  
  MondoTextFieldCell *mondoCell = [self cell];
  [mondoCell setButtonSize:[[zoomButton image] size]];
  
  return zoomButton;
}

- (void)awakeFromNib {
  _attrDict = [[NSDictionary dictionaryWithObject: [self font] forKey:NSFontAttributeName] retain];
  
  [self createMondoTextFieldCell];
  [self createButtonForControlHeight];
  // We don't want any animation on startup
  // Prevents the button from being displayed for a split second
  // and fading out.
  [[NSAnimationContext currentContext] setDuration:0.0];
  [self displayButtonIfNeeded];

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
  
  NSButton* zoomButton = [self zoomButton];
  
  [zoomButton setTarget: self];
  [zoomButton setAction: @selector(zoomButtonPressed:)];

}

- (void) zoomButtonPressed: (id) sender {
   NSButton* zoomButton = [self zoomButton];
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
  
  [[MondoZoomWindowController sharedMondoZoomWindowController] showWindow:self]; 
  
}

- (void)dealloc {
	[_attrDict release];
	[super dealloc];

}

- (void)setFrame:(NSRect)frameRect {
  // SetFrame is called Interface Builder when changing the size
  // of the component.
  if ( NSHeight([self frame]) != NSHeight(frameRect) ) {    
    [self createButtonForControlHeight];
  }
  
  if ( NSWidth([self frame]) != NSWidth(frameRect) ) {    
    [self positionButton:frameRect];
  }
  
  
  [super setFrame:frameRect];

  [self displayButtonIfNeeded];
}

- (void)positionButton:(NSRect)forFrame {
  NSButton* zoomButton = [self zoomButton];
  NSSize buttonSize = [[zoomButton image] size];
  float height = (NSHeight(forFrame) - (buttonSize.height)) / 2;  // Centre the button.
  [zoomButton setFrame:NSMakeRect( NSWidth(forFrame) - (buttonSize.width + BUTTON_RIGHT_MARGIN) , 
                                  height, buttonSize.width, buttonSize.height)];
}

- (void)windowBecameOrResignedKey:(NSNotification *)aNotification {
     // Forces the focus ring to be drawn correctly
		[[self window] display];
}

- (void)setStringValue:(NSString *)aString {
  [super setStringValue:aString];
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
  NSButton* zoomButton = [self zoomButton];
  float textViewportWidth = NSWidth([self frame]) - ([[zoomButton image] size].width + HORIZ_MARGIN * 2);
  BOOL buttonVisible = [self stringWidth] > textViewportWidth;
  [[zoomButton animator] setAlphaValue: (buttonVisible ? VISIBLE : INVISIBLE)];
}

-(void)setWindowTitle:(NSString *)title {
  [title retain];
  [windowTitle release];
  windowTitle = title;
}

- (NSString*) fieldLabel {
  // Window title was set in the inspector 
  // attributes.
  if(windowTitle) {
    return windowTitle;    
  }
  
  // We are binding to a textfield label.
  NSString* title =  [windowTitleTextField stringValue];
  if(title) {
    return title;
  }
  
  // Someone was lazy and didn't set a title.  Show the 
  // window with a blank title.
  return @"";
}


@end

