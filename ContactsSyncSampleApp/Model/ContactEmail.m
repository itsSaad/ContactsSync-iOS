//
//  ContactEmail.m
//  ContactsSyncSampleApp
//
//  Created by Saad Masood on 11/17/14.
//  Copyright (c) 2014 QBXNet Ltd. All rights reserved.
//

#import "ContactEmail.h"



@implementation ContactEmail

+(NSArray *) getAllEmailsWithRecordID:(ABRecordID) recordID forAddressBook:(ABAddressBookRef) addressBook
{
    NSMutableArray *allEmails = [NSMutableArray array];
    
    ABRecordRef ref = ABAddressBookGetPersonWithRecordID(addressBook, recordID);
    
    CFTypeRef emailProperty = ABRecordCopyValue(ref, kABPersonEmailProperty);
    int valueCount = (int)ABMultiValueGetCount(emailProperty);
    for (int count = 0; count < valueCount; count++)
    {
        ContactEmail * anEmail = [[ContactEmail alloc]init];
        anEmail.label = (__bridge NSString *)(ABMultiValueCopyLabelAtIndex(emailProperty, count));
        anEmail.identifier = ABMultiValueGetIdentifierAtIndex(emailProperty, count);
        anEmail.value = (__bridge NSString *)(ABMultiValueCopyValueAtIndex(emailProperty, count));
        [allEmails addObject:anEmail];
    }
    
    return (NSArray *)allEmails;
}


+(NSArray *) dictRepresentationFor:(NSArray *) emails
{
    NSMutableArray * dictEmail = [[NSMutableArray alloc]init];
    
    for (ContactEmail * anEmail in emails)
    {
        NSMutableDictionary *aDictPhone = [[NSMutableDictionary alloc]init];
        
        [aDictPhone setValue:anEmail.label forKey:@"label"];
        [aDictPhone setValue:[NSNumber numberWithInteger:anEmail.identifier] forKey:@"identifier"];
        [aDictPhone setValue:anEmail.value forKey:@"value"];
        
        [dictEmail addObject:aDictPhone];
    }
    
    return dictEmail;
}

@end
