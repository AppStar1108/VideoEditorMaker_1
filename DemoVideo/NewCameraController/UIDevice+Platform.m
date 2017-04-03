//
//  UIDevice+Platform.m
//


#import "UIDevice+Platform.h"
#include <sys/types.h>
#include <sys/sysctl.h>


@implementation UIDevice (Platform)

- (NSString *)platform
{
  size_t size;
  
  // Set 'oldp' parameter to NULL to get the size of the data
  // returned so we can allocate appropriate amount of space
  sysctlbyname("hw.machine", NULL, &size, NULL, 0); 
  
  // Allocate the space to store name
  char *name = malloc(size);
  
  // Get the platform name
  sysctlbyname("hw.machine", name, &size, NULL, 0);
  
  // Place name into a string
  NSString *machine = [NSString stringWithUTF8String:name];
  
  // Done with this
  free(name);
  
  return machine;
}

- (NSString *)platformString
{
  NSString *platform = [self platform];
  
  if ([platform isEqualToString:@"i386"])             return @"Simulator x32";
  else if ([platform isEqualToString:@"x86_64"])      return @"Simulator x64";
  
  else if ([platform isEqualToString:@"iPod1,1"])     return @"iPod Touch 1st Gen";
  else if ([platform isEqualToString:@"iPod2,1"])     return @"iPod Touch 2nd Gen";
  else if ([platform isEqualToString:@"iPod3,1"])     return @"iPod Touch 3rd Gen";
  else if ([platform isEqualToString:@"iPod4,1"])     return @"iPod Touch 4th Gen";
  else if ([platform isEqualToString:@"iPod5,1"])     return @"iPod Touch 5th Gen";
  
  else if ([platform isEqualToString:@"iPhone1,1"])   return @"iPhone";
  else if ([platform isEqualToString:@"iPhone1,2"])   return @"iPhone 3G";
  else if ([platform isEqualToString:@"iPhone1,2*"])  return @"iPhone 3G (China)";
  else if ([platform isEqualToString:@"iPhone2,1"])   return @"iPhone 3GS";
  else if ([platform isEqualToString:@"iPhone2,1*"])  return @"iPhone 3GS (China)";
  else if ([platform isEqualToString:@"iPhone3,1"])   return @"iPhone 4";
  else if ([platform isEqualToString:@"iPhone3,2"])   return @"iPhone 4";
  else if ([platform isEqualToString:@"iPhone3,3"])   return @"iPhone 4 (CDMA)";
  else if ([platform isEqualToString:@"iPhone4,1"])   return @"iPhone 4S";
  else if ([platform isEqualToString:@"iPhone5,1"])   return @"iPhone 5";
  else if ([platform isEqualToString:@"iPhone5,2"])   return @"iPhone 5 (CDMA)";
  
  else if ([platform isEqualToString:@"iPad1,1"])     return @"iPad";
  else if ([platform isEqualToString:@"iPad2,1"])     return @"iPad 2 (Wi-Fi)";
  else if ([platform isEqualToString:@"iPad2,2"])     return @"iPad 2 (Wi-Fi + GSM)";
  else if ([platform isEqualToString:@"iPad2,3"])     return @"iPad 2 (Wi-Fi + CDMA)";
  else if ([platform isEqualToString:@"iPad2,4"])     return @"iPad 2 New (Wi-Fi + CDMA)";
  else if ([platform isEqualToString:@"iPad2,5"])     return @"iPad Mini (Wi-Fi)";
  else if ([platform isEqualToString:@"iPad3,1"])     return @"iPad 3rd Gen (Wi-Fi)";
  else if ([platform isEqualToString:@"iPad3,2"])     return @"iPad 3rd Gen (Wi-Fi + GSM)";
  else if ([platform isEqualToString:@"iPad3,3"])     return @"iPad 3rd Gen (Wi-Fi + CDMA)";
  else if ([platform isEqualToString:@"iPad3,4"])     return @"iPad 4rd Gen";
  
  else
    NSLog(@"Unknown device model!");
  
  return @"Unknown";
}

- (NSInteger)platformRAM
{
  NSString *platform = [self platform];
  
  if ([platform isEqualToString:@"iPod1,1"])          return 128;
  else if ([platform isEqualToString:@"iPod2,1"])     return 128;
  else if ([platform isEqualToString:@"iPod3,1"])     return 256;
  else if ([platform isEqualToString:@"iPod4,1"])     return 256;
  else if ([platform isEqualToString:@"iPod5,1"])     return 256;
  
  else if ([platform hasPrefix:@"iPhone1,"])          return 128;
  else if ([platform hasPrefix:@"iPhone2,"])          return 256;
  else if ([platform hasPrefix:@"iPhone3,"])          return 512;
  else if ([platform hasPrefix:@"iPhone4,"])          return 512;
  else if ([platform hasPrefix:@"iPhone5,"])          return 1024;
  
  else if ([platform hasPrefix:@"iPad1,"])            return 256;
  else if ([platform hasPrefix:@"iPad2,"])            return 512;
  else if ([platform hasPrefix:@"iPad3,"])            return 1024;
  
  else
    NSLog(@"Unknown RAM size!");
  
  return 0;
}



@end









