//
//  TableViewController.m
//  CNContactExample
//
//  Created by SuHan Kim on 09/02/2018.
//  Copyright © 2018 edcan. All rights reserved.
//

#import "TableViewController.h"

@interface TableViewController () <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) CNContactStore *contactStore;
@property(nonatomic, strong) NSMutableArray<CNContact *> *contacts;

@end

@implementation TableViewController

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.contacts count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Contact"];
    UILabel *label = [cell.contentView.subviews objectAtIndex:0];
    
    CNContact *contact = [self.contacts objectAtIndex:indexPath.row];
    NSMutableString *string = [[NSMutableString alloc] init];
    [string appendString: contact.givenName];
    [string appendString: @"\n"];
    [contact.emailAddresses enumerateObjectsUsingBlock:^(CNLabeledValue<NSString *> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [string appendString: obj.value];
        [string appendString: @"\n"];
    }];
    
    [label setText:string];
    
    return cell;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.contactStore requestAccessForEntityType:CNEntityTypeContacts
                                completionHandler:^(BOOL granted, NSError * _Nullable error) {
                                    if (granted){
                                        [self refresh];
                                    }
                                }
    ];
}

- (void)refresh{
    NSError *error;
    self.contacts = [NSMutableArray new];
    [self.contactStore enumerateContactsWithFetchRequest:[[CNContactFetchRequest alloc] initWithKeysToFetch: [[NSArray alloc] initWithObjects:CNContactGivenNameKey, CNContactEmailAddressesKey, nil]]
                                                   error:&error
                                              usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
                                                  [self.contacts addObject:contact];
                                              }
    ];
    
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self.tableView reloadData];
    });
}

- (CNContactStore *)contactStore{
    if (_contactStore != nil){
        return _contactStore;
    }
    
    _contactStore = [[CNContactStore alloc] init];
    return _contactStore;
}

@end
