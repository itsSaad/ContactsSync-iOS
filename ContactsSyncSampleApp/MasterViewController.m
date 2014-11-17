//
//  MasterViewController.m
//  ContactsSyncSampleApp
//
//  Created by Saad Masood on 11/11/14.
//  Copyright (c) 2014 QBXNet Ltd. All rights reserved.
//

#import "MasterViewController.h"
#import "AFNetworking.h"

@import AddressBook;
@import AddressBookUI;

@interface MasterViewController ()

@property (nonatomic) ABAddressBookRef book;
@property (strong, nonatomic) NSArray *allContacts;
@property (strong, nonatomic) NSMutableDictionary * currentUser;

@end

@implementation MasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(syncContacts)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    self.currentUser = [[NSMutableDictionary alloc]init];
    self.currentUser[@"first_name"] = @"Saad";
    self.currentUser[@"last_name"] = @"Masood";
    self.currentUser[@"phones"] = @[@"+923219428808"];
    self.currentUser[@"emails"] = @[@"itssaad@icloud.com"];
    
    
    
    [self checkAddressBook];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self syncContacts];
}



#pragma mark - Contacts Thingy

-(void)checkAddressBook
{
    //Checks the Auth Status for fetching contacts.
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)
    {
        //Yes we can access contacts. Yay! :)
        [self fetchAllContacts];
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined)
    {
        if ([self canAccessContacts:self.book])
        {
            [self fetchAllContacts];
        }
        else
        {
            //User Denied Access. :(
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Contact Access" message:@"You need to provide contact access to use this App. Please allow this app in Settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    else
    {
        //Access Already Restricted. :(
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Contact Access" message:@"You need to provide contact access to use this App. Please allow this app in Settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(BOOL)canAccessContacts:(ABAddressBookRef)book
{
    __block BOOL accessGranted = NO;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    ABAddressBookRequestAccessWithCompletion(book, ^(bool granted, CFErrorRef error)
    {
        accessGranted = granted;
        dispatch_semaphore_signal(sema);
    });
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    if (accessGranted)
    {
        return YES;
    }
    return NO;
}

-(void)fetchAllContacts
{
    NSMutableArray * allPersons = [[NSMutableArray alloc]init];
    //Get the Contacts now.
    CFErrorRef error;
    self.book = ABAddressBookCreateWithOptions(NULL, &error);
    // Get all People from Address Book
    CFArrayRef allContacts = ABAddressBookCopyArrayOfAllPeople(self.book);
    CFIndex totalContacts = ABAddressBookGetPersonCount(self.book);
    for (int i = 0; i < totalContacts; i++)
    {
        ABRecordRef aPerson = CFArrayGetValueAtIndex(allContacts, i);
        NSMutableDictionary * aRecord = [[NSMutableDictionary alloc] init];
        NSString * recID = [NSString stringWithFormat:@"%ld", (long)ABRecordGetRecordID(aPerson)];
        NSString * recName = (__bridge NSString *)(ABRecordCopyCompositeName(aPerson));
        if (!recName)
        {
            recName = @"No Name";
        }
        [aRecord setObject:recID forKey:@"recordID"];
        [aRecord setObject:recName forKey:@"recordName"];
        [aRecord setObject:(__bridge id)(aPerson) forKey:@"recordRef"];
        [allPersons addObject:aRecord];
    }
    self.allContacts = (NSArray *)allPersons;
    
}

-(void) syncContacts
{
    
    
    //Lets send over the contacts.
    dispatch_queue_t aQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(aQueue, ^(){
       //Lets gather all the contacts first.
        NSMutableArray  * allCompleteContacts = [[NSMutableArray alloc]init];
        for (NSDictionary *aContact in self.allContacts)
        {
            //Get all the data for aContact.
            NSMutableDictionary *completeInfo = [[NSMutableDictionary alloc]init];
            ABRecordRef contactRecord = (__bridge ABRecordRef)(aContact[@"recordRef"]);
            NSString * firstName = (__bridge id)(ABRecordCopyValue(contactRecord, kABPersonFirstNameProperty));
            NSString * middleName = (__bridge id)(ABRecordCopyValue(contactRecord, kABPersonMiddleNameProperty));
            NSString * lastName = (__bridge id)(ABRecordCopyValue(contactRecord, kABPersonLastNameProperty));
            NSString * namePrefix = (__bridge NSString *)(ABRecordCopyValue(contactRecord, kABPersonPrefixProperty));
            NSString * nameSuffix = (__bridge NSString *)(ABRecordCopyValue(contactRecord, kABPersonSuffixProperty));
            NSString * nickname = (__bridge id)(ABRecordCopyValue(contactRecord, kABPersonNicknameProperty));
            NSString * organizationName = (__bridge id)(ABRecordCopyValue(contactRecord, kABPersonOrganizationProperty));
            NSString * jobTitle = (__bridge id)(ABRecordCopyValue(contactRecord, kABPersonJobTitleProperty));
            NSString * departmentName = (__bridge id)(ABRecordCopyValue(contactRecord, kABPersonDepartmentProperty));
            NSDate * birthday = (__bridge id)(ABRecordCopyValue(contactRecord, kABPersonBirthdayProperty));
            NSString * note = (__bridge id)(ABRecordCopyValue(contactRecord, kABPersonNoteProperty));
            NSDate * creationDate = (__bridge id)(ABRecordCopyValue(contactRecord, kABPersonCreationDateProperty));
            NSDate * modificationDate = (__bridge id)(ABRecordCopyValue(contactRecord, kABPersonModificationDateProperty));
            
            
            CFTypeRef phoneProperty = ABRecordCopyValue(contactRecord, kABPersonPhoneProperty);
            NSArray *phones = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(phoneProperty);
            
            CFTypeRef emailProp = ABRecordCopyValue(contactRecord, kABPersonEmailProperty);
            NSArray * emails = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(emailProp);
            
            if (!firstName)
            {
                firstName = @"";
            }
            if (!middleName)
            {
                middleName = @"";
            }
            if (!lastName)
            {
                lastName = @"";
            }
            if (!namePrefix)
            {
                namePrefix = @"";
            }
            if (!nameSuffix)
            {
                nameSuffix = @"";
            }
            if (!nickname)
            {
                nickname = @"";
            }
            if (!organizationName)
            {
                organizationName = @"";
            }
            if (!jobTitle)
            {
                jobTitle = @"";
            }
            if (!departmentName)
            {
                departmentName = @"";
            }
            if (!birthday)
            {
                birthday = [[NSDate alloc] initWithTimeIntervalSince1970:NSTimeIntervalSince1970];
            }
            if (!note)
            {
                note = @"";
            }
            
            if (!phones)
            {
                phones = @[];
            }
            if (!emails)
            {
                emails = @[];
            }
            
            //Conclude the contact.
            completeInfo[@"first_name"] = firstName;
            completeInfo[@"middle_name"] = middleName;
            completeInfo[@"last_name"] = lastName;
            completeInfo[@"job_title"] = jobTitle;
            completeInfo[@"department"] = departmentName;
            completeInfo[@"organization"] = organizationName;
            completeInfo[@"prefix"] = namePrefix;
            completeInfo[@"suffix"] = nameSuffix;
            completeInfo[@"birthdate"] = birthday;
            completeInfo[@"note"] = note;
            completeInfo[@"creation_date"] = creationDate;
            completeInfo[@"modification_date"] = modificationDate;
            [completeInfo setObject:phones forKey:@"phones"];
            [completeInfo setObject:emails forKey:@"emails"];
            
            [allCompleteContacts addObject:completeInfo];
        }
        
        
        
        //Now lets upload all to the server.
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
        NSString * apiKey = [[NSUserDefaults standardUserDefaults] objectForKey:@"api_key"];
        [params setObject:allCompleteContacts forKey:@"contacts"];
        [params setObject:self.currentUser forKey:@"user"];
        [manager POST:[NSString stringWithFormat:@"http://192.168.1.15:3000/api/v1/users/sync_contacts.json?api_key=%@", apiKey] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
        {
            NSLog(@"JSON: %@", responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error)
        {
            NSLog(@"Error: %@", error);
        }];
    });
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"contactDetail"])
    {
//        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//        NSDictionary * object = [self.allContacts objectAtIndex:indexPath.row];
//        NSInteger recordID = [[object objectForKey:@"recordID"] integerValue];
//        ABPersonViewController * vc = [segue destinationViewController];
//        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
//        vc.displayedPerson = ABAddressBookGetPersonWithRecordID(addressBook, (int32_t)recordID);
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.allContacts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    if (!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.textLabel.text = [[self.allContacts objectAtIndex:indexPath.row] objectForKey:@"recordName"];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
            
        NSError *error = nil;
        if (![context save:&error])
        {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * object = [self.allContacts objectAtIndex:indexPath.row];
    NSInteger recordID = [[object objectForKey:@"recordID"] integerValue];
    ABPersonViewController * vc = [[ABPersonViewController alloc] init];
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    vc.displayedPerson = ABAddressBookGetPersonWithRecordID(addressBook, (int32_t)recordID);
    vc.addressBook = addressBook;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
