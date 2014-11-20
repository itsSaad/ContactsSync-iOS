//
//  ContactPhone.m
//  ContactsSyncSampleApp
//
//  Created by Saad Masood on 11/17/14.
//  Copyright (c) 2014 QBXNet Ltd. All rights reserved.
//

#import "ContactPhone.h"

@implementation ContactPhone

+(NSArray *) getAllPhonesWithRecordID:(ABRecordID) recordID forAddressBook:(ABAddressBookRef) addressBook
{
    NSMutableArray *allPhones = [NSMutableArray array];
    
    ABRecordRef ref = ABAddressBookGetPersonWithRecordID(addressBook, recordID);
    
    CFTypeRef phoneProperty = ABRecordCopyValue(ref, kABPersonPhoneProperty);
    int valueCount = (int)ABMultiValueGetCount(phoneProperty);
    for (int count = 0; count < valueCount; count++)
    {
        ContactPhone * aPhone = [[ContactPhone alloc]init];
        aPhone.label = (__bridge NSString *)(ABMultiValueCopyLabelAtIndex(phoneProperty, count));
        aPhone.identifier = ABMultiValueGetIdentifierAtIndex(phoneProperty, count);
        aPhone.value = (__bridge NSString *)(ABMultiValueCopyValueAtIndex(phoneProperty, count));
        [allPhones addObject:aPhone];
    }
    
    return (NSArray *)allPhones;
}

+(NSArray *) dictRepresentationFor:(NSArray *) phones
{
    NSMutableArray * dictPhones = [[NSMutableArray alloc]init];
    
    for (ContactPhone * aPhone in phones)
    {
        NSMutableDictionary *aDictPhone = [[NSMutableDictionary alloc]init];
        [aDictPhone setValue:aPhone.label forKey:@"label"];
        [aDictPhone setValue:[NSNumber numberWithInteger:aPhone.identifier] forKey:@"identifier"];
        [aDictPhone setValue:aPhone.value forKey:@"value"];
        
        [dictPhones addObject:aDictPhone];
    }
    return dictPhones;
}
@end
