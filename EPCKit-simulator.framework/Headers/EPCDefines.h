//
//  EPCDefines.h
//
//  Created by Everton Cunha on 08/08/12.
//


/*
 Misc helpers.
 */
#define fstr(obj, ...) (NSString*)[NSString stringWithFormat:obj, __VA_ARGS__]


/*
 Angle helpers.
 */
#define degreesToRadians(x) (M_PI * (x) / 180.0)
#define radiansToDegrees(x) (180.0*(x)/ M_PI)


/*
 UIColor helpers.
 */
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define UIColorFromRGB_A(rgbValue, a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]


/*
 Check iOS Version.
 */
#define IOS_VERSION_LESS_THAN(string) ([[[UIDevice currentDevice] systemVersion] compare:string options:NSNumericSearch] == NSOrderedAscending)


/*
 Logging
*/
#ifdef DEBUG
#    define DLog(...) NSLog(__VA_ARGS__)
#else
#    define DLog(...) /* */
#endif


/*
 Device
 */
#define DEVICE_IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define DEVICE_IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )