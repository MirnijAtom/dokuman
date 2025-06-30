#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The resource bundle ID.
static NSString * const ACBundleID AC_SWIFT_PRIVATE = @"MirnijAtom.DokuMan";

/// The "AppTeal" asset catalog color resource.
static NSString * const ACColorNameAppTeal AC_SWIFT_PRIVATE = @"AppTeal";

/// The "GermanFlag" asset catalog image resource.
static NSString * const ACImageNameGermanFlag AC_SWIFT_PRIVATE = @"GermanFlag";

/// The "UKFlag" asset catalog image resource.
static NSString * const ACImageNameUKFlag AC_SWIFT_PRIVATE = @"UKFlag";

/// The "scannerIcon" asset catalog image resource.
static NSString * const ACImageNameScannerIcon AC_SWIFT_PRIVATE = @"scannerIcon";

#undef AC_SWIFT_PRIVATE
