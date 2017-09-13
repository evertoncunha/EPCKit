//
//  EPCAddressBook.m
//
//  Created by Everton Cunha on 15/03/13.
//

#import "EPCAddressBook.h"
#import <AddressBook/AddressBook.h>
#import "EPCDefines.h"

@implementation EPCAddressBook

- (void)dealloc
{
	CFRelease(_addressBook);
    [super dealloc];
}

+ (EPCAddressBook*)singleton {
	static id obj = nil;
	if (!obj) {
		obj = [[EPCAddressBook alloc] init];
	}
	return obj;
}

- (BOOL)hasAccessToAddressBook {
	if (IOS_VERSION_LESS_THAN(@"6.0")) {
		return YES;
	}
	
	ABAuthorizationStatus status =  ABAddressBookGetAuthorizationStatus();
	
	if (status == kABAuthorizationStatusNotDetermined) {
		return [self requestAddressBookAccess];
	}
	
	return status == kABAuthorizationStatusAuthorized;
}

+ (BOOL)hasAccessToAddressBook {
	return [[self singleton] hasAccessToAddressBook];
}

void addressBookChanged(ABAddressBookRef ab, CFDictionaryRef info, void *context){
	[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationAddressBookChanged object:nil];
}

- (BOOL)requestAddressBookAccess {
	__block BOOL accessGranted = NO;
	
	if (ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6
		dispatch_semaphore_t sema = dispatch_semaphore_create(0);
		
		if (!_addressBook) {
			_addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
			ABAddressBookRegisterExternalChangeCallback(_addressBook, addressBookChanged, self);
		}
		ABAddressBookRequestAccessWithCompletion(_addressBook, ^(bool granted, CFErrorRef error) {
			accessGranted = granted;
			dispatch_semaphore_signal(sema);
		});
		
		dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
		dispatch_release(sema);
	}
	else { // we're on iOS 5 or older
		if (!_addressBook) {
			_addressBook = ABAddressBookCreate();
			ABAddressBookRegisterExternalChangeCallback(_addressBook, addressBookChanged, self);
		}
		accessGranted = YES;
	}
	return accessGranted;

}

+ (BOOL)requestAddressBookAccess {
	return [[self singleton] requestAddressBookAccess];
}

+ (NSArray *)allContacts {
	return [[self singleton] allContacts];
}

- (NSArray *)allContacts {
	
	[self requestAddressBookAccess];
	
    
	if (![self hasAccessToAddressBook]) {
		return nil;
	}
	
	NSCharacterSet *numbersSet = [NSCharacterSet decimalDigitCharacterSet];
	
    //Creates an NSArray from the CFArrayRef using toll-free bridging
    CFArrayRef arrayOfPeople = ABAddressBookCopyArrayOfAllPeople(_addressBook);
	
	CFIndex count = CFArrayGetCount(arrayOfPeople);
	
	NSMutableArray *mut = [NSMutableArray arrayWithCapacity:count];
	
	for (CFIndex i = 0 ; i < count; i++) {
		
		EPCAddressBookPerson *pp = [[EPCAddressBookPerson alloc] init];
		[mut addObject:pp];
		[pp release];
		
		ABRecordRef person = CFArrayGetValueAtIndex(arrayOfPeople, i);
		
		pp.recordRef = person;
		
		CFStringRef value = ABRecordCopyValue(person, kABPersonFirstNameProperty);
		if (value != NULL) {
			pp.name = (id)value;
			CFRelease(value);
		}
		
		value = ABRecordCopyValue(person, kABPersonLastNameProperty);
		if (value != NULL) {
			pp.lastName = (id)value;
			CFRelease(value);
		}
		
		value = ABRecordCopyValue(person, kABPersonOrganizationProperty);
		if (value != NULL) {
			pp.companyName = (id)value;
			CFRelease(value);
		}
		
		
		//
		// phones
		
		ABMutableMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
        CFIndex phoneNumberCount = ABMultiValueGetCount( phoneNumbers );
		
		NSMutableArray *phones = nil;
		if (phoneNumberCount > 0) {
			phones = [NSMutableArray arrayWithCapacity:phoneNumberCount];
			pp.phones = phones;
		}
		
        for (int k = 0; k < phoneNumberCount; k++)
		{
			NSMutableDictionary *mutDict = [NSMutableDictionary dictionaryWithCapacity:4];
			[phones addObject:mutDict];
			
            CFStringRef phoneNumberLabel = ABMultiValueCopyLabelAtIndex( phoneNumbers, k );
            CFStringRef phoneNumberValue = ABMultiValueCopyValueAtIndex( phoneNumbers, k );
            CFStringRef phoneNumberLocalizedLabel = ABAddressBookCopyLocalizedLabel( phoneNumberLabel );
		
			if (phoneNumberLabel != NULL)
				[mutDict setObject:(id)phoneNumberLabel forKey:@"label"];
				
			if (phoneNumberLocalizedLabel != NULL)
				[mutDict setObject:(id)phoneNumberLocalizedLabel forKey:@"labelLocalized"];
		
			if (phoneNumberValue != NULL) {
				[mutDict setObject:(id)phoneNumberValue forKey:@"numberFormatted"];
			}
			
			NSMutableString *cleanNumber = nil;
			
			if (phoneNumberValue != NULL) {
				cleanNumber = [[NSMutableString alloc] initWithString:(id)phoneNumberValue];
				int i = 0;
				while (i < [cleanNumber length]) {
					if ([numbersSet characterIsMember:[cleanNumber characterAtIndex:i]]) {
						i++;
					}
					else {
						[cleanNumber replaceCharactersInRange:NSMakeRange(i, 1) withString:@""];
					}
				}
				if ([cleanNumber length] > 0) {
					[mutDict setObject:cleanNumber forKey:@"number"];
				}
				else {
					[mutDict setObject:@"" forKey:@"number"];
				}
				[cleanNumber release];
			}
			else {
				[mutDict setObject:@"" forKey:@"number"];
			}
			
            CFRelease(phoneNumberLocalizedLabel);
            CFRelease(phoneNumberLabel);
            CFRelease(phoneNumberValue);
		}
		
		CFRelease(phoneNumbers);
	
		
		//
		// emails
		
		ABMutableMultiValueRef emailsValues = ABRecordCopyValue(person, kABPersonEmailProperty);
		CFIndex emailsCount = ABMultiValueGetCount( emailsValues );
		NSMutableArray *emails = nil;
		if (emailsCount > 0) {
			emails = [NSMutableArray arrayWithCapacity:emailsCount];
			pp.emails = emails;
		}
		
		for (int k = 0; k < emailsCount; k++)
		{
			NSMutableDictionary *mutDict = [NSMutableDictionary dictionaryWithCapacity:3];
			[emails addObject:mutDict];
			
            CFStringRef emailLabel = ABMultiValueCopyLabelAtIndex( emailsValues, k );
            CFStringRef emailValue = ABMultiValueCopyValueAtIndex( emailsValues, k );
			CFStringRef emailLocalizedLabel = ABAddressBookCopyLocalizedLabel( emailLabel );
			
			if (emailLocalizedLabel != NULL)
				[mutDict setObject:(id)emailLocalizedLabel forKey:@"label"];

			if (emailValue != NULL) {
				[mutDict setObject:(id)emailValue forKey:@"email"];
			}
			
			CFRelease(emailLabel);
			CFRelease(emailValue);
			CFRelease(emailLocalizedLabel);
		}
		
		CFRelease(emailsValues);
		
	}
	
	CFRelease(arrayOfPeople);
	
	return mut;
}

@end


@implementation EPCAddressBookPerson

- (void)dealloc
{
    self.name = nil;
	self.middleName = nil;
	self.lastName = nil;
	self.companyName = nil;
	self.phones = nil;
	self.emails = nil;
	self.recordRef = nil;
    [super dealloc];
}

- (NSString *)contactName {
	if (self.name && self.lastName) {
		return [self.name stringByAppendingFormat:@" %@", self.lastName];
	}
	if (self.name) {
		return self.name;
	}
	if (self.lastName) {
		return self.lastName;
	}
	if (self.middleName) {
		return self.middleName;
	}
	if (self.companyName) {
		return self.companyName;
	}
	return nil;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"name: %@, middle: %@, last: %@, company: %@, phones: %@, emails: %@", self.name, self.middleName, self.lastName, self.companyName, self.phones, self.emails];
}

- (UIImage *)image {
	if(ABPersonHasImageData(_recordRef)) {
		NSData *data = (NSData *)ABPersonCopyImageData(_recordRef);
		UIImage *img = [UIImage imageWithData:data];
		CFRelease(data);
		return img;
	}
	return nil;
}
@end