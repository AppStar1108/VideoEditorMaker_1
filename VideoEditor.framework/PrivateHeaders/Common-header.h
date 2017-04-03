
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//#import "UIDevicePlatform.h"
#import "UIDevice+Platform_VE.h"
// UI Helpers
#define DevicePlateform   [UIDevicePlatform objDeviceClass]

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568.0 ) < DBL_EPSILON )

#define iPhone6 ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && MAX([UIScreen mainScreen].bounds.size.height,[UIScreen mainScreen].bounds.size.width) == 667)
#define iPhone6Plus ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && MAX([UIScreen mainScreen].bounds.size.height,[UIScreen mainScreen].bounds.size.width) == 736)

#define DisplayAlertWithTitle(msg,title) {UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]; [alertView show];}
#define imageName(imageName)  [UIImage imageNamed:imageName]
#define enableTouch(enable)   [[UIApplication sharedApplication].keyWindow setUserInteractionEnabled:enable];

#define XSET_OBJECT(k,v) [[NSUserDefaults standardUserDefaults] setObject:v forKey:k];
#define XSYNC [[NSUserDefaults standardUserDefaults] synchronize];

#define    WINDOW_WIDTH             [UIScreen mainScreen].applicationFrame.size.width    ///< i.e. for iPhone it is 320 for portrait and 300 for landscape orientation
#define    WINDOW_HEIGHT            [UIScreen mainScreen].applicationFrame.size.height   ///< i.e. for iPhone it is 460 for portrait and 480 for landscape orientation
#define    WINDOW_WIDTH_ORIENTED    (IsPortrait ? WINDOW_WIDTH : WINDOW_HEIGHT)          ///< i.e. 320 for portrait and 480 for landscape orientation
#define    WINDOW_HEIGHT_ORIENTED   (IsPortrait ? WINDOW_HEIGHT : WINDOW_WIDTH)          ///< i.e. 460 for portrait and 320 for landscape orientation

#define    SCREEN_WIDTH             [UIScreen mainScreen].bounds.size.width
#define    SCREEN_HEIGHT            [UIScreen mainScreen].bounds.size.height
#define    SCREEN_WIDTH_ORIENTED    (IsPortrait ? SCREEN_WIDTH : SCREEN_HEIGHT)
#define    SCREEN_HEIGHT_ORIENTED   (IsPortrait ? SCREEN_HEIGHT : SCREEN_WIDTH)

#define    TOOLBAR_HEIGHT           44.
#define    TABBAR_HEIGHT            49.

#define    KEYBOARD_SIZE_PORTRAIT   (IsIPhone ? CGSizeMake(320, 216) : CGSizeMake(768, 264))
#define    KEYBOARD_SIZE_LANDSCAPE  (IsIPhone ? CGSizeMake(480, 162) : CGSizeMake(1024, 352))
#define    KEYBOARD_SIZE            (IsPortrait ? KEYBOARD_SIZE_PORTRAIT : KEYBOARD_SIZE_LANDSCAPE)

#define SCREENSIZE [[UIScreen mainScreen] bounds].size.height

#define kFontAvenirBlack      @"Avenir-Black"
#define kFontAvenirMedium     @"Avenir-Medium"
#define kFontAvenirRoman      @"Avenir-Roman"
#define kFontArial            @"ArialMT"
#define kFontCooperBlack      @"CooperBlackStd"
#define kFontImpact           @"Impact"
#define kFontAppleCasual      @"AppleCasual"

// Debug functions
#pragma mark - Debug functions

#define   SHOW_LOGS             YES
#define   SHOW_TEXTURES_LOGS    NO
#define   Log(format, ...)      if (SHOW_LOGS) NSLog(@"%s: %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:format, ## __VA_ARGS__]);
#define   TexLog(format, ...)   if (SHOW_LOGS && SHOW_TEXTURES_LOGS) NSLog(@"%s: %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:format, ## __VA_ARGS__]);
#define   Error(format, ...)    if (SHOW_LOGS) NSLog(@"ERROR: %@", [NSString stringWithFormat:format, ## __VA_ARGS__]);

// Hardware Info
#pragma mark - Hardware Info

#define   SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define   IsIOS4_3        (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"4.3"))
#define   IsIOS5          (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0"))
#define   IsIOS6          (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0"))
#define   IsIOS7          (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))


#define   IsIPad          isIPad()
#define   IsIPhone        !isIPad()
#define   IsRetina        isRetina()

// Default Paths
#pragma mark - Paths

#define   BundlePath                    [[NSBundle mainBundle] resourcePath]
#define   PathToResource(resourceName)  [BundlePath stringByAppendingPathComponent:resourceName]

#define   DocumentsPath                 [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define   LibraryPath                   [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define   SharedDataPath                DocumentsPath

#define   CriticalDataPath              criticalDataPath()
#define   OfflineDataPath               offlineDataPath()
#define   CachedDataPath                [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define   TemporaryDataPath             [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"]

// Misc
#pragma mark - Misc

#define   Localized(string)         NSLocalizedString(string, @"")

#define   CGRectGetCenter(rect)     CGPointMake(floorf(0.5 * rect.size.width), floorf(0.5 * rect.size.height))
#define   CGRectGetMidPoint(rect)   CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect))

#define   CGAffineTransformGetScale(transform)        CGPointMake(sqrtf(transform.a * transform.a + transform.c * transform.c), sqrtf(transform.b * transform.b + transform.d * transform.d))
#define   CGAffineTransformGetRotateAngle(transform)  atan2f(transform.b, transform.a)
#define SharedObj   [HMSharedClass sharedInstance]

#define XDEL_OBJECT(k) [[NSUserDefaults standardUserDefaults] removeObjectForKey:k];
#define XGET_OBJECT(v) [[NSUserDefaults standardUserDefaults] objectForKey:v]
#define XSET_OBJECT(k,v) [[NSUserDefaults standardUserDefaults] setObject:v forKey:k];
#define XGET_STRING(v) [[NSUserDefaults standardUserDefaults] stringForKey:v]
#define XSET_STRING(k,v) [[NSUserDefaults standardUserDefaults] setObject:v forKey:k];
#define XGET_FLOAT(v) [[NSUserDefaults standardUserDefaults] floatForKey:v]
#define XSET_FLOAT(k,v) [[NSUserDefaults standardUserDefaults] setFloat:v forKey:k];
#define XGET_BOOL(v) [[NSUserDefaults standardUserDefaults] boolForKey:v]
#define XSET_BOOL(k,v) [[NSUserDefaults standardUserDefaults] setBool:v forKey:k];
#define XGET_INT(v) [[NSUserDefaults standardUserDefaults] integerForKey:v]
#define XSET_INT(k,v) [[NSUserDefaults standardUserDefaults] setInteger:v forKey:k];
#define XSYNC [[NSUserDefaults standardUserDefaults] synchronize];



BOOL isIPad();
BOOL isRetina();
#define IsIphone5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

BOOL addSkipBackupAttributeToFile(NSString *filePath);

NSString *criticalDataPath();
NSString *offlineDataPath();

id loadNib(Class aClass, NSString *nibName, id owner);

CGSize CGSizeScaledToFitSize(CGSize size1, CGSize size2);
CGSize CGSizeScaledToFillSize(CGSize size1, CGSize size2);
CGRect CGRectWithSize(CGSize size);
CGRect CGRectFillRect(CGRect rect1, CGRect rect2);

CGRect CGRectExpandToLabel(UILabel *label);

void ShowAlert(NSString *title, NSString *message);

void CustomizeNavBar();

UIColor *UIColorFromHex(int hexColor);

