

// TODO -- insert copyright...

#import "PPCommon.h"


@implementation PPImageUtils


+ (NSImage*)cropImage:(NSImage*)sourceImage withRect:(NSRect)sourceRect {
  
  NSImage* cropImage = [[NSImage alloc] initWithSize:NSMakeSize(sourceRect.size.width, sourceRect.size.height)];
  [cropImage lockFocus];
  {
    [sourceImage drawInRect:NSMakeRect(0, 0, sourceRect.size.width, sourceRect.size.height)
                   fromRect:sourceRect 
                  operation:NSCompositeSourceOver fraction:1.0];
  }
  [cropImage unlockFocus];
  
  [cropImage autorelease];
  return cropImage;
}

+ (CGImageRef)createCGRefFromNSImage:(NSImage*)image {
  NSSize size = [image size];
  
  float desiredPixelWidth = size.width;
  float desiredPixelHeight = size.height;
  
  CGContextRef bitmapCtx = CGBitmapContextCreate(NULL/*data - pass NULL to let CG allocate the memory */, 
                                                 desiredPixelWidth,  
                                                 desiredPixelHeight, 
                                                 8 /*bitsPerComponent*/, 
                                                 0 /*bytesPerRow - CG will calculate it for you if it's allocating the data.  
                                                    This might get padded out a bit for better alignment*/, 
                                                 [[NSColorSpace genericRGBColorSpace] CGColorSpace], 
                                                 kCGBitmapByteOrder32Host|kCGImageAlphaPremultipliedFirst);
  
  [NSGraphicsContext saveGraphicsState];
  [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithGraphicsPort:bitmapCtx flipped:NO]];
  
  [image drawInRect:NSMakeRect(0,0, desiredPixelWidth, desiredPixelHeight) 
           fromRect:NSZeroRect/*sentinel, means "the whole thing*/ 
          operation:NSCompositeCopy fraction:1.0];
  
  [NSGraphicsContext restoreGraphicsState];
  
  CGImageRef imageRef = CGBitmapContextCreateImage(bitmapCtx);
  CFRelease(bitmapCtx);
  
  return imageRef;
}



@end
