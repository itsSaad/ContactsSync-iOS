//
//  ContactPhone.h
//  ContactsSyncSampleApp
//
//  Created by Saad Masood on 11/17/14.
//  Copyright (c) 2014 QBXNet Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AddressBook/AddressBook.h"

@interface ContactPhone : NSObject

@property (nonatomic) NSInteger identifier;
@property (strong, nonatomic) NSString * label;
@property (strong, nonatomic) NSString * value;

+(NSArray *) getAllPhonesWithRecordID:(ABRecordID) recordID forAddressBook:(ABAddressBookRef) addressBook;
+(NSArray *) dictRepresentationFor:(NSArray *) phones;

@end
