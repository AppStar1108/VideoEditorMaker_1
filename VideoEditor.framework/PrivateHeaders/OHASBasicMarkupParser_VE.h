
#import "OHASMarkupParserBase_VE.h"

/*!
 * Supported tags:
 *
 *  "*bold*" to write text in bold
 *
 *  "_underline_" to write text underlined
 *
 *  "|italics|" to write text in italics
 *
 *  "`typewritter font`" to write text in Courier (fixed-width) font
 *
 *  "[some text](some URL)" to create a link to "some URL" with displayed text "some text"
 *
 * Colors:
 *  - use "{color|text}" like in "{#fc0|some purple text}" and "{#00ff00|some green text}"
 *  - It also support named colors like in "{red|some red text}" "{green|some green text}", "{blue|some blue text}"
 *
 * 
 */
@interface OHASBasicMarkupParser : OHASMarkupParserBase

@end
