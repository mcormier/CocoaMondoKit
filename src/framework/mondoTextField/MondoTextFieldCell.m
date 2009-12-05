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
#import "MondoTextFieldCell.h"
#import "MondoTextField.h"

@interface MondoTextFieldCell(Private)
  - (NSRect)textRectForFrame:(NSRect)frame;
@end


@implementation MondoTextFieldCell

- (id)initWithCell:(NSTextFieldCell*)oldCell {
	self = [super initTextCell:[oldCell stringValue]];
	if (self) {
    _buttonSize = NSZeroSize;
    
    // Grab the properties of the old cell define in Interface Builder
    [self setContinuous:[oldCell isContinuous]];
    [self setSendsActionOnEndEditing:[oldCell sendsActionOnEndEditing]];
    [self setEditable:[oldCell isEditable]];
    [self setDrawsBackground:[oldCell drawsBackground]];
    [self setWraps:[oldCell wraps]];
    [self setScrollable:[oldCell isScrollable]];
    [self setAlignment:[oldCell alignment]];
    [self setBordered:[oldCell isBordered]];
    [self setBezeled:[oldCell isBezeled]];
    [self setFont:[oldCell font]];
	}
	return self;
}


- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {    
  // Let the super view handle drawing the text portion of the field
	[super drawInteriorWithFrame:[self textRectForFrame:cellFrame] inView:controlView];

}

// Gets called when the parent text field is made the first responder
- (void)selectWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj 
               delegate:(id)anObject start:(NSInteger)selStart length:(NSInteger)selLength {

  [super selectWithFrame:[self textRectForFrame:aRect]
                  inView:controlView
                  editor:textObj
                delegate:anObject
                   start:selStart
                  length:selLength];
}

- (void)resetCursorRect:(NSRect)cellFrame inView:(NSView *)controlView {
    [super resetCursorRect:[self textRectForFrame:cellFrame] inView:controlView];
}

- (NSRect)textRectForFrame:(NSRect)frame {  
  frame.size.width -= _buttonSize.width;     
  return frame;
}

- (void)setButtonSize:(NSSize)size {
  _buttonSize = size;
}

@end





