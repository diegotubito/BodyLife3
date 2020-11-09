#ifdef __OBJC__
#import <Cocoa/Cocoa.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "BLServerManager.h"

FOUNDATION_EXPORT double BLServerManagerVersionNumber;
FOUNDATION_EXPORT const unsigned char BLServerManagerVersionString[];

