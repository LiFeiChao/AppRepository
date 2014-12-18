//
//  DAO.m
//  IntelligentCommunity
//
//  Created by 高 欣 on 13-4-16.
//  Copyright (c) 2013年 com.ideal. All rights reserved.
//

#import "DAO.h"
#import "AppDelegate.h"

@implementation DAO
- (id)init {
    self = [super init];
    if (self) {
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        self.managedObjectContext = delegate.managedObjectContext;
    }
    return self;
}

+ (DAO *)shareDAO {
    static DAO *dao = nil;
    static dispatch_once_t onceDao;
    dispatch_once(&onceDao, ^{
        dao = [[DAO alloc] init];
    });
    return dao;
}


#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsControllerWithDelegate:(id) delegate EntityName:(NSString*) entityName SortKeys:(NSArray*) sortKeys CacheName:(NSString*) cacheName
{
    return [self fetchedResultsControllerWithDelegate:delegate EntityName:entityName Predicate:nil SortKeys:sortKeys CacheName:cacheName];
}


- (NSFetchedResultsController *)fetchedResultsControllerWithDelegate:(id) delegate EntityName:(NSString*) entityName Predicate:(NSPredicate*) predicate SortKeys:(NSArray*) sortKeys CacheName:(NSString*) cacheName
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:entityName
                                   inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    if(predicate){
        [fetchRequest setPredicate:predicate];
    }
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    NSMutableArray *sortDescriptors=[[NSMutableArray alloc] init];
    // Edit the sort key as appropriate.
    [sortKeys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKeys[idx] ascending:NO];
        [sortDescriptors addObject:sortDescriptor];
    }];
    [fetchRequest setSortDescriptors:sortDescriptors];
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:cacheName];
    aFetchedResultsController.delegate = delegate;
    //self.fetchedResultsController = aFetchedResultsController;
	NSError *error = nil;
	if (![aFetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    CLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    return aFetchedResultsController;
}

-(NSFetchRequest*) fetchRequestWithEntityName:(NSString*) entityName Predicate:(NSPredicate*) predicate SortKeys:(NSArray*) sortKeys
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *fetch = [[NSFetchRequest alloc]init];
    [fetch setEntity:entity];
    
    [fetch setPredicate:predicate];
    
    return fetch;
}


#pragma mark - Operation Methods

- (BOOL)saveObject
{
    NSError *error;
    [self.managedObjectContext save:&error];
    if (error) {
        CLog(@"Save fault! Error msg: %@", [error description]);
        return NO;
    }
    return YES;
}

-(void) deleteObject:(NSManagedObject*) object
{
    [self.managedObjectContext deleteObject:object];
    [self saveObject];
}

-(void) deleteObjectsWithEntityName:(NSString *)entityName Predicate:(NSPredicate*) predicate
{
    NSArray *arrayDelete=[self queryObjectWithEntityName:entityName Predicate:predicate SortKeys:nil];
    [arrayDelete enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self.managedObjectContext deleteObject:obj];
    }];
    [self saveObject];
}

- (NSManagedObject *) newInsertObject:(NSString *)managedObjectName
{ 
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:managedObjectName inManagedObjectContext:self.managedObjectContext];
    return newManagedObject;
}

- (NSArray *)queryObjectWithEntityName:(NSString *)entityName Predicate:(NSPredicate*) predicate SortKeys:(NSArray*) sortKeys
{
    NSFetchRequest *fetchRequest=[self fetchRequestWithEntityName:entityName Predicate:predicate SortKeys:sortKeys];
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    return error?nil:results;
}

@end
