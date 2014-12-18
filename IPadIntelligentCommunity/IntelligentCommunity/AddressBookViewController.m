//
//  AddressBookViewController.m
//  IntelligentCommunity
//
//  Created by 高 欣 on 13-7-12.
//  Copyright (c) 2013年 com.ideal. All rights reserved.
//

#import "AddressBookViewController.h"
#import "UserCenterViewController.h"
#import "Region.h"
#import "RegionCell.h"
#import "User.h"
#import "ContactsCell.h"
#import "UIView+NibLoading.h"
#import "Util.h"
#import "I18NControl.h"

#define IMAGE_CHANGED @"imageChanged"

@interface AddressBookViewController (){
    IBOutlet UISearchBar *_searchBar;
    int _selectedMainTableViewIndex;
    NSArray *_selectedSubContactsArray;
}

@property (strong,nonatomic) IBOutlet UITableView *mainTableView;

@property (strong,nonatomic) NSMutableArray *addressBookArray;
@end

@implementation AddressBookViewController

@synthesize btnRefresh;

UserCenterViewController *userCenterVC;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _selectedMainTableViewIndex=-1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _searchBar.placeholder = [[I18NControl bundle] localizedStringForKey:@"inputSearchName" value:nil table:nil];
    self.navigationItem.titleView = _searchBar;
//    UIBarButtonItem *barButtonItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(getAddressBook)];
    btnRefresh=[UIButton buttonWithType:UIButtonTypeCustom];
    btnRefresh.frame=(CGRect){CGPointZero,48,44};
    [btnRefresh setImage:[UIImage imageNamed:@"refresh_btn_h@2x.png"] forState:UIControlStateNormal];
    //[btnRefresh setImage:[UIImage imageNamed:@"refresh_btn_h@2x.png"] forState:UIControlStateHighlighted];
    [btnRefresh addTarget:self action:@selector(getAddressBook) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem=[[UIBarButtonItem alloc] initWithCustomView:btnRefresh];
    
    self.navigationItem.rightBarButtonItem = barButtonItem;
    
    self.addressBookArray = [NSMutableArray array];
     
    _mainTableView.tableFooterView=[[UIView alloc] init];
    _subTableView.tableFooterView=[[UIView alloc] init];
    _mainTableView.separatorColor=RGBColor(200, 200, 200);
    _subTableView.separatorColor=RGBColor(200, 200, 200);
    
    _mainTableView.backgroundColor=RGBColor(232, 236, 236);
    //_subTableView.backgroundColor=RGBColor(65, 136, 210);
    
    _mainTableView.dataSource=self;
    _mainTableView.delegate=self;
    _subTableView.dataSource=self;
    _subTableView.delegate=self;
    [self getAddressBook];
    
    userCenterVC=[[UserCenterViewController alloc] initWithNibName:@"UserCenterViewController" bundle:nil];
    userCenterVC.adressBookVC = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subTableViewReloadData) name:IMAGE_CHANGED object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Table View


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView.tag==0){
        return self.addressBookArray.count;
    }else{
        if(_selectedMainTableViewIndex==-1){
            return 0;
        }
        //自动选择第一项
        if(_selectedSubContactsArray.count>0){
            
            double delayInSeconds = .2;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:0];
                [self.subTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionBottom];
                User *user=_selectedSubContactsArray[indexPath.row];
                
                userCenterVC=[[UserCenterViewController alloc] initWithNibName:@"AdressUserCenterVC" bundle:nil];
                userCenterVC.user=user;
                
                self.splitVC.detailViewController=userCenterVC;
            });
           
        }
        return _selectedSubContactsArray.count;
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.tag==0){
        static NSString *cellIdentifier =@"MainTableCell";
        RegionCell *cell = (RegionCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell=(RegionCell*)[[RegionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.textLabel.font=[UIFont systemFontOfSize:15.0f];
            cell.selectionStyle=UITableViewCellSelectionStyleGray;
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.backgroundColor=[UIColor clearColor];
        }
    
        _selectedMainTableViewIndex=indexPath.row;
        Region *region=self.addressBookArray[_selectedMainTableViewIndex];
        cell.textLabel.text=region.regionName;

        return cell;
    }else{
        static NSString *cellIdentifier =@"SubTableCell";
        ContactsCell *cell = (ContactsCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = (ContactsCell*)[ContactsCell loadInstanceFromNib];
            //cell.selectionStyle=UITableViewCellSelectionStyleNone;
            //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.accessoryView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"indicator"]];
            cell.selectionStyle=UITableViewCellSelectionStyleGray;
 
            
        }
        User *user=_selectedSubContactsArray[indexPath.row];
        cell.user=user;
        //cell.textLabel
        return cell;
    }
    
    
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    cell.accessoryView.backgroundColor = RGBColor(65, 139, 210);
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return tableView.tag==0?44:100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.tag==0){
        _selectedMainTableViewIndex=indexPath.row;
        Region *region=self.addressBookArray[_selectedMainTableViewIndex];
        _selectedSubContactsArray=region.usersArray;
        [self.subTableView reloadData];
    }else{
        User *user=_selectedSubContactsArray[indexPath.row];
        
        NSLog(@"名字是 ： %@,   部门是： %@", user.userName, user.department );
        
        UserCenterViewController *userCenterVC=[[UserCenterViewController alloc] initWithNibName:@"AdressUserCenterVC" bundle:nil];
        userCenterVC.user=user;
        
        self.splitVC.detailViewController=userCenterVC;
    }
}
//-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
//    
//}

#pragma mark - UISearchBar Delegate Methods

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}

/*键盘搜索按钮*/

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    _selectedSubContactsArray=[self searchUser:searchBar.text];
    [_subTableView reloadData];
    [_mainTableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:_selectedMainTableViewIndex inSection:0] animated:NO];
    //[self searchProductWithKeyword:nil searchWord:searchBar.text];
}

#pragma mark - Custom Methods


-(NSArray*) searchUser:(NSString*) searchKey
{
    NSMutableArray *resultArray=[[NSMutableArray alloc] init];
    [self.addressBookArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Region *region=obj;
        [region.usersArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            User *user=obj;
            if ([user.userName rangeOfString:searchKey].location != NSNotFound) {
                [resultArray addObject:user];
            }
        }];
    }];
    return resultArray;
    
}
-(void) getAddressBook
{
    self.splitVC.detailViewController=[[UIViewController alloc] init];
    NSDictionary *dicParams=@{@"language":[Util getCurrentLanguage]};
    //NSDictionary *dicParams=@{@"userID":[AppController sharedInstance].user.userID};
    [Util showLoadingDialog];
    [[AFIntelligentCommunityClient sharedClient] getPath:@"ContactsInterface/getContactsList" parameters:dicParams success:^(AFHTTPRequestOperation *operation, id JSON) {
        CLog(@"%@",JSON);
        [self.addressBookArray removeAllObjects];
        _selectedMainTableViewIndex=-1;
//        NSString *path = [[NSBundle mainBundle] pathForResource:@"contacts" ofType:@"txt"];
//        NSString* content = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
//        NSData *JSONData = [content dataUsingEncoding:NSUTF8StringEncoding];
//        NSArray *contactsArray = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableContainers error:nil];
        NSArray *contactsArray = JSON;
        [contactsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *contactsDict=obj;
            Region *region=[[Region alloc] init];
            region.regionID=contactsDict[@"bID"];
            region.regionName=contactsDict[@"bName"];
            NSArray *contactsArray=contactsDict[@"contacts"];
            NSMutableArray *subUsersArray=[[NSMutableArray alloc] init];
            [contactsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSDictionary *contactsDict=obj;
                User *user=[[User alloc] init];
                user.userID=contactsDict[@"id"];
                user.userName=contactsDict[@"name"];
                user.avatarUrl=contactsDict[@"iconURL"];
                user.mobile=contactsDict[@"mobileNumber"];
                user.email=contactsDict[@"email"];
                user.sign=contactsDict[@"pSign"];
                user.brief=contactsDict[@"briefIntro"];
                user.enterprise=contactsDict[@"enterprise"];
                user.department=contactsDict[@"department"];
                [subUsersArray addObject:user];
            }];
            region.usersArray=subUsersArray;
            [self.addressBookArray addObject:region];
        }];
        if(_selectedMainTableViewIndex==-1){
            _selectedMainTableViewIndex=0;
            Region *region=self.addressBookArray[_selectedMainTableViewIndex];
            _selectedSubContactsArray=region.usersArray;
        }
        [_mainTableView reloadData];
        [_subTableView reloadData];
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:_selectedMainTableViewIndex inSection:0];
        [self.mainTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionBottom];
      
        [Util dismissDialog];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //[[NSNotificationCenter defaultCenter] postNotificationName:DFNotificationShowLoading object:nil userInfo:nil];
        CLog(@"%@",operation);
        [Util failOperation:operation.responseData];
        [Util dismissDialog];
         
    }];
}

-(void) subTableViewReloadData
{
    [self getAddressBook];
}

@end
