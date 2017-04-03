
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Text Alignment Convertion
/////////////////////////////////////////////////////////////////////////////////////

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000
  #define NSUITextAlignment NSTextAlignment
  #define NSUILineBreakMode NSLineBreakMode
#else
  #define NSUITextAlignment UITextAlignment
  #define NSUILineBreakMode UILineBreakMode
#endif
extern CTTextAlignment CTTextAlignmentFromUITextAlignment(NSUITextAlignment alignment);
extern CTLineBreakMode CTLineBreakModeFromUILineBreakMode(NSUILineBreakMode lineBreakMode);

/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Flipping Coordinates
/////////////////////////////////////////////////////////////////////////////////////

CGPoint CGPointFlipped(CGPoint point, CGRect bounds);
CGRect CGRectFlipped(CGRect rect, CGRect bounds);

/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSRange / CFRange
/////////////////////////////////////////////////////////////////////////////////////

NSRange NSRangeFromCFRange(CFRange range);

/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - CoreText CTLine/CTRun utils
/////////////////////////////////////////////////////////////////////////////////////

CGRect CTLineGetTypographicBoundsAsRect(CTLineRef line, CGPoint lineOrigin);
CGRect CTRunGetTypographicBoundsAsRect(CTRunRef run, CTLineRef line, CGPoint lineOrigin);
CGRect CTRunGetTypographicBoundsForRangeAsRect(CTRunRef run, CTLineRef line, CGPoint lineOrigin, CFRange range, CGContextRef ctx);
BOOL CTLineContainsCharactersFromStringRange(CTLineRef line, NSRange range);
BOOL CTRunContainsCharactersFromStringRange(CTRunRef run, NSRange range);
