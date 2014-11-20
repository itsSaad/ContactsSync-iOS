//
//  Contact.h
//  ContactsSyncSampleApp
//
//  Created by Saad Masood on 11/17/14.
//  Copyright (c) 2014 QBXNet Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AddressBook/AddressBook.h"
#import "ContactEmail.h"
#import "ContactPhone.h"

@interface Contact : NSObject

@property (strong, nonatomic) NSString * firstName;
@property (strong, nonatomic) NSString * middleName;
@property (strong, nonatomic) NSString * lastName;
@property (strong, nonatomic) NSString * namePrefix;
@property (strong, nonatomic) NSString * nameSuffix;
@property (strong, nonatomic) NSString * nickname;
@property (strong, nonatomic) NSString * compositeName;
@property (strong, nonatomic) NSString * jobTitle;
@property (strong, nonatomic) NSString * departmentName;
@property (strong, nonatomic) NSString * organizationName;
@property (strong, nonatomic) NSDate * birthdate;
@property (strong, nonatomic) NSString * note;
@property (strong, nonatomic) NSDate * creationDate;
@property (strong, nonatomic) NSDate * modificationDate;
@property ABRecordRef recordRef;
@property ABRecordID recordID;

@property (strong, nonatomic) NSArray * phones;
@property (strong, nonatomic) NSArray * emails;


-(id) initWithRecordID:(ABRecordID) recordID forAddressBook:(ABAddressBookRef)addressBook;
+(NSDictionary *) dictRepresenationFor:(NSArray *)contacts;
@end
