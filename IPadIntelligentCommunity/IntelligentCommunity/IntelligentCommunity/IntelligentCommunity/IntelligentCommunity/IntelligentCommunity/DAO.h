//
//  DAO.h
//  IntelligentCommunity
//
//  Created by 高 欣 on 13-4-16.
//  Copyright (c) 2013年 com.ideal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DAO : NSObject

@property (weak, nonatomic) NSManagedObjectContext *managedObjectContext;

+ (DAO *)shareDAO;
//保存数据
- (BOOL)saveObject;
//删除单条数据
- (void) deleteObject:(NSManagedObject*) object;
//根据数据对象名称和条件删除多条数据
- (void) deleteObjectsWithEntityName:(NSString *)entityName Predicate:(NSPredicate*) predicate;
//创建新增数据实例
- (NSManagedObject *) newInsertObject:(NSString *)managedObjectName;
//根据一系列参数返回NSFetchedResultsController实例
- (NSFetchedResultsController *)fetchedResultsControllerWithDelegate:(id) delegate EntityName:(NSString*) entityName SortKeys:(NSArray*) sortKeys CacheName:(NSString*) cacheName;
- (NSFetchedResultsController *)fetchedResultsControllerWithDelegate:(id) delegate EntityName:(NSString*) entityName Predicate:(NSPredicate*) predicate SortKeys:(NSArray*) sortKeys CacheName:(NSString*) cacheName;
//根据一系列参数返回NSFetchRequest实例
-(NSFetchRequest*) fetchRequestWithEntityName:(NSString*) entityName Predicate:(NSPredicate*) predicate SortKeys:(NSArray*) sortKeys;
//根据数据对象名称和条件查询数据
- (NSArray *)queryObjectWithEntityName:(NSString *)entityName Predicate:(NSPredicate*) predicate SortKeys:(NSArray*) sortKeys;
@end
