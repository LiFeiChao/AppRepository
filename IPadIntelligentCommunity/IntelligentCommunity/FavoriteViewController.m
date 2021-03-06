//
//  FavoriteViewController.m
//  IntelligentCommunity
//
//  Created by 高 欣 on 13-4-11.
//  Copyright (c) 2013年 com.ideal. All rights reserved.
//

#import "FavoriteViewController.h"
#import "DetailViewController.h"
#import "FavoriteProduct.h"
#import "Product.h"
#import "ProductCell.h"
#import "UIView+NibLoading.h"
#import "DAO.h"
#import "I18NControl.h"
#import "ProductDetailViewController.h"
#import "MedianViewController.h"


#define CLOSE_MASKVIEW @"close_maskView"
#define SELECT_NULL @"select_null"
#define degreesToRadian(x) (M_PI * (x) / 180.0)

@interface FavoriteViewController (){
    //DAO *_dao;
    IBOutlet UITableView *_tableView;
    UIBarButtonItem *_editButtonItem;
    NSIndexPath *_selectedIndexPath;
}

@property (strong,nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) UIBarButtonItem *rightBarButtonItem;
@property (strong,nonatomic) UIView *maskView;

@end

UIView *detailView;
UIView *lineView;
MedianViewController *medianVC;

@implementation FavoriteViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"userID == %@",
                            [AppController sharedInstance].userInfo.userID];

    self.fetchedResultsController=[[DAO shareDAO] fetchedResultsControllerWithDelegate:self EntityName:@"FavoriteProduct"  Predicate:predicate SortKeys:@[@"storeDate"] CacheName:nil];
    _editButtonItem=[[UIBarButtonItem alloc] initWithTitle:[[I18NControl bundle] localizedStringForKey:@"edit" value:nil table:nil] style:UIBarButtonItemStylePlain target:self action:@selector(editTable:)];
    
    //self.editButtonItem.possibleTitles = [NSSet setWithObjects:@"编辑", @"完成", nil];
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         */
        CLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    


    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeDetailVC) name:CLOSE_MASKVIEW object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectNull) name:SELECT_NULL object:nil];

}


- (void) viewWillDisappear:(BOOL)animated
{
    detailView = nil;
    lineView = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Table view data source methods

/*
 The data source methods are handled primarily by the fetch results controller
 */

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    
//    int count=[[self.fetchedResultsController sections] count];
//    if(count>0){
//        f
//        double delayInSeconds = .2;
//        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:0];
//            [_tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionBottom];
//            DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
//            FavoriteProduct *favoriteProduct=[self.fetchedResultsController objectAtIndexPath:indexPath];
//            Product *product = [[Product alloc] init];
//            product.productID=favoriteProduct.productID;
//            product.imageUrl=favoriteProduct.imageUrl;
//            product.productName=favoriteProduct.productName;
//            product.briefIntroduction=favoriteProduct.briefIntroduction;
//            detailViewController.product = product;
//            self.splitVC.detailViewController=detailViewController;
//        });
//        
//    }
//    return count;
//}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    NSUInteger count=[sectionInfo numberOfObjects];
    
    if(count>0){
        self.navigationItem.rightBarButtonItem=_editButtonItem;
        double delayInSeconds = .2;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
          
            
            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:0];
            [_tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionBottom];
        
            for (UIView *view in _maskView.subviews) {
                [view removeFromSuperview];
            }
            
            if (!medianVC) {
                medianVC = [[MedianViewController alloc] initWithNibName:@"MedianViewController" bundle:nil];
                
            }else{
                [medianVC removeFromParentViewController];
            }
            
            ProductDetailViewController *detailViewController = [[ProductDetailViewController alloc] initWithNibName:@"ProductDetailViewController" bundle:nil];
            
            [detailViewController.toolbar setHidden:NO];
            
            FavoriteProduct *favoriteProduct = [self.fetchedResultsController objectAtIndexPath:indexPath];
            Product *product = [[Product alloc] init];
            product.productID=favoriteProduct.productID;
            product.imageUrl=favoriteProduct.imageUrl;
            product.productName=favoriteProduct.productName;
            product.briefIntroduction=favoriteProduct.briefIntroduction;
            detailViewController.productInfo = product;
            
            [self.splitVC.detailViewController addChildViewController: medianVC];
            [self.splitVC.detailViewController.view addSubview:medianVC.view];
            
            [medianVC addChildViewController: detailViewController];
            
            detailView=detailViewController.view;
            detailView.frame=(CGRect){ -1, 0,447,748};
        
            if(!self.maskView){
                self.maskView=[[UIView alloc] initWithFrame:(CGRect){self.view.bounds.size.width, 0,447,748}];
                
                _maskView.backgroundColor=RGBColor(239, 241, 243);
                [[_maskView layer] setShadowOffset:CGSizeMake(-2, 2)];
                
                [[_maskView layer] setShadowOpacity:.5];
                [[_maskView layer] setShadowColor:[UIColor blackColor].CGColor];
            }else{
              self.maskView.frame = (CGRect){447, 0, 447,748};
            }

            [_maskView addSubview:detailView];
            
            [medianVC.view addSubview:_maskView];
            
            [UIView animateWithDuration:.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                _maskView.frame=(CGRect){ 0 ,0, 447,748};
            }completion:nil];

            
        });
        
    }else{
        self.navigationItem.rightBarButtonItem=nil;
        [self setEditBarButtonWithEditing:NO];
    }
        return count;
}


// Customize the appearance of table view cells.

- (void)configureCell:(ProductCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    // Configure the cell to show the book's title
    FavoriteProduct *favoriteProduct=[self.fetchedResultsController objectAtIndexPath:indexPath];
    Product *product = [[Product alloc] init];
    product.productID=favoriteProduct.productID;
    product.imageUrl=favoriteProduct.imageUrl;
    product.productName=favoriteProduct.productName;
    product.briefIntroduction=favoriteProduct.briefIntroduction;
    cell.product=product;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ProductCell";
    
    ProductCell *cell = (ProductCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = (ProductCell*)[ProductCell loadInstanceFromNib];
        cell.accessoryView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"indicator"]];
        cell.selectionStyle=UITableViewCellSelectionStyleGray;
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    for (UIView *view in _maskView.subviews) {
        [view removeFromSuperview];
    }

    _selectedIndexPath=indexPath;
    ProductDetailViewController *detailViewController = [[ProductDetailViewController alloc] initWithNibName:@"ProductDetailViewController" bundle:nil];
    
    [detailViewController.toolbar setHidden:NO];
    
    FavoriteProduct *favoriteProduct=[self.fetchedResultsController objectAtIndexPath:indexPath];
    Product *product = [[Product alloc] init];
    product.productID=favoriteProduct.productID;
    product.imageUrl=favoriteProduct.imageUrl;
    product.productName=favoriteProduct.productName;
    product.briefIntroduction=favoriteProduct.briefIntroduction;
    detailViewController.productInfo = product;
    if (!medianVC) {
        medianVC = [[MedianViewController alloc] initWithNibName:@"MedianViewController" bundle:nil];
        
        [self.splitVC.detailViewController addChildViewController: medianVC];
        [self.splitVC.detailViewController.view addSubview:medianVC.view];
    }
    
    [medianVC addChildViewController: detailViewController];
    
    detailView=detailViewController.view;
    detailView.frame=(CGRect){ -1, 0,447,748};
    
  
    
    if(!self.maskView){
        self.maskView=[[UIView alloc] initWithFrame:(CGRect){self.view.bounds.size.width, 0,447,748}];
        
        _maskView.backgroundColor=RGBColor(239, 241, 243);
        [[_maskView layer] setShadowOffset:CGSizeMake(-2, 2)];
        
        [[_maskView layer] setShadowOpacity:.5];
        [[_maskView layer] setShadowColor:[UIColor blackColor].CGColor];
    }
    
    self.maskView.frame = (CGRect){447, 0, 447,748};

    [_maskView addSubview:detailView];
    
    [medianVC.view addSubview:_maskView];
    
    [UIView animateWithDuration:.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _maskView.frame=(CGRect){ 0 ,0, 447,748};
    }completion:nil];
    }

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 74;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    // Display the authors' names as section headings.
    return [[[self.fetchedResultsController sections] objectAtIndex:section] name];
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [[I18NControl bundle] localizedStringForKey:@"delete" value:nil table:nil];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // Delete the managed object.
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error;
        if (![context save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             */
            CLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


#pragma mark -
#pragma mark Table view editing


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

-(void) editTable:(id) sender
{
    BOOL editing=!_tableView.editing;
    [self setEditBarButtonWithEditing:editing];
}

-(void) setEditBarButtonWithEditing:(BOOL) editing
{
    _editButtonItem.title=editing?[[I18NControl bundle] localizedStringForKey:@"done" value:nil table:nil]:[[I18NControl bundle] localizedStringForKey:@"edit" value:nil table:nil];
    [_tableView setEditing:editing animated:YES];
}


#pragma mark -
#pragma mark Fetched results controller

/*
 NSFetchedResultsController delegate methods to respond to additions, removals and so on.
 */

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [_tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            if ([_selectedIndexPath compare:indexPath]==NSOrderedSame) {
                self.splitVC.detailViewController=[[UIViewController alloc] init];
            }
            
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(ProductCell*)[_tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [_tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [_tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [_tableView endUpdates];
}

-(void) closeDetailVC
{
    //UIView *detailView=self.detailViewController.view;
    
    
    [UIView animateWithDuration:.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _maskView.frame=(CGRect){self.view.bounds.size.width,0,447,748};
    }completion:^(BOOL finished) {
        //        [self.splitVC.detailViewController.view removeFromSuperview];
        
        [_maskView removeFromSuperview];
    }];
}

- (void) selectNull
{
    [_tableView selectRowAtIndexPath:nil animated:NO scrollPosition:UITableViewScrollPositionBottom];
}

@end
