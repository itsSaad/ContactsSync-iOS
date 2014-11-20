//
//  Contact.m
//  ContactsSyncSampleApp
//
//  Created by Saad Masood on 11/17/14.
//  Copyright (c) 2014 QBXNet Ltd. All rights reserved.
//

#import "Contact.h"
#import "AddressBook/AddressBook.h"

@implementation Contact


-(id) initWithRecordID:(ABRecordID) recordID forAddressBook:(ABAddressBookRef)addressBook
{
    if (!addressBook)
    {
        CFErrorRef error;
        addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    }
    Contact *aContact = [[Contact alloc] init];
    aContact.recordID = recordID;
    NSLog(@"Retrieving contact with RecordID: %d", aContact.recordID);
    ABRecordRef ref = ABAddressBookGetPersonWithRecordID(addressBook, recordID);
    if (ref)
    {
        aContact.firstName = (__bridge NSString *)(ABRecordCopyValue(ref, kABPersonFirstNameProperty));
        aContact.middleName = (__bridge NSString *)(ABRecordCopyValue(ref, kABPersonMiddleNameProperty));
        aContact.lastName = (__bridge NSString *)(ABRecordCopyValue(ref, kABPersonLastNameProperty));
        aContact.namePrefix = (__bridge NSString *)(ABRecordCopyValue(ref, kABPersonPrefixProperty));
        aContact.nameSuffix = (__bridge NSString *)(ABRecordCopyValue(ref, kABPersonSuffixProperty));
        aContact.nickname = (__bridge NSString *)(ABRecordCopyValue(ref, kABPersonNicknameProperty));
        aContact.organizationName = (__bridge NSString *)(ABRecordCopyValue(ref, kABPersonOrganizationProperty));
        aContact.jobTitle = (__bridge NSString *)(ABRecordCopyValue(ref, kABPersonJobTitleProperty));
        aContact.departmentName = (__bridge NSString *)(ABRecordCopyValue(ref, kABPersonDepartmentProperty));
        aContact.birthdate = (__bridge id)(ABRecordCopyValue(ref, kABPersonBirthdayProperty));
        aContact.note = (__bridge NSString *)(ABRecordCopyValue(ref, kABPersonNoteProperty));
        aContact.creationDate = (__bridge id)(ABRecordCopyValue(ref, kABPersonCreationDateProperty));
        aContact.modificationDate = (__bridge id)(ABRecordCopyValue(ref, kABPersonModificationDateProperty));
        
        aContact.phones = [ContactPhone getAllPhonesWithRecordID:aContact.recordID forAddressBook:addressBook];
        aContact.emails = [ContactEmail getAllEmailsWithRecordID:aContact.recordID forAddressBook:addressBook];
    }
    return aContact;
}

+(NSArray *) dictRepresenationFor:(NSArray *)contacts
{
    NSMutableArray * allContacts = [[NSMutableArray alloc]init];
    for (Contact * aContact in contacts)
    {
        NSMutableDictionary *dictContact = [[NSMutableDictionary alloc]init];
        
        [dictContact setValue:aContact.firstName forKey:@"first_name"];
        [dictContact setValue:aContact.middleName forKey:@"middle_name"];
        [dictContact setValue:aContact.lastName forKey:@"last_name"];
        [dictContact setValue:aContact.namePrefix forKey:@"prefix"];
        [dictContact setValue:aContact.nameSuffix forKey:@"suffix"];
        [dictContact setValue:aContact.nickname forKey:@"nickname"];
        [dictContact setValue:aContact.organizationName forKey:@"organization"];
        [dictContact setValue:aContact.jobTitle forKey:@"job_title"];
        [dictContact setValue:aContact.departmentName forKey:@"department"];
        [dictContact setValue:aContact.birthdate forKey:@"birthdate"];
        [dictContact setValue:aContact.note forKey:@"note"];
        [dictContact setValue:aContact.creationDate forKey:@"creation_date"];
        [dictContact setValue:aContact.modificationDate forKey:@"modification_date"];
        [dictContact setValue:[ContactPhone dictRepresentationFor:aContact.phones] forKey:@"phones"];
        [dictContact setValue:[ContactEmail dictRepresentationFor:aContact.emails] forKey:@"emails"];
        
        [allContacts addObject:dictContact];
    }
    return (NSArray *)allContacts;
}


@end
