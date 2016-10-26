//
//  EPCAddressBook.h
//
//  Created by Everton Cunha on 15/03/13.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define kNotificationAddressBookChanged @"kNotificationAddressBookChanged" // This can be fired multiple times while the AdddressBook is syncing

@interface EPCAddressBook : NSObject {
	id _addressBook;
}

+ (NSArray*)allContacts;

+ (BOOL)requestAddressBookAccess;

+ (BOOL)hasAccessToAddressBook;

@end

@interface EPCAddressBookPerson : NSObject
@property (copy) NSString *name, *lastName, *middleName, *companyName;
@property (strong) NSArray *phones, *emails;
@property (readonly) NSString *contactName; // first and last, middle or company
@property (strong) id recordRef;
- (UIImage*)image;
@end