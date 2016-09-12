//
//  IDYVideoManagerTableViewController.m
//  testDemo
//
//  Created by qiyun on 16/9/12.
//  Copyright © 2016年 qiyun. All rights reserved.
//

#import "IDYVideoManagerTableViewController.h"
#import <objc/runtime.h>

@interface IDYVideoManagerTableViewController ()

@end

@implementation IDYVideoManagerTableViewController

NSObject *getter(id self, SEL _cmd){
    
    NSString *name = NSStringFromSelector(_cmd);
    NSString *ivarName = [self ivarName:name];
    
    Ivar ivar = class_getInstanceVariable([self class], [ivarName UTF8String]);
    return object_getIvar(self, ivar);
}

+ (NSString*)ivarName:(NSString *)name
{
    NSRange r;
    r.length = name.length -1 ;
    r.location = 1;
    
    NSString* firstChar = [name stringByReplacingCharactersInRange:r withString:@""].lowercaseString;
    
    if([firstChar isEqualToString:@"_"])
        return name;
    
    r.length = 1;
    r.location = 0;
    
    NSString* theRest = [name stringByReplacingCharactersInRange:r withString:@""];
    
    return [NSString stringWithFormat:@"_%@%@",firstChar, theRest];
}

void setter(id self, SEL _cmd, NSObject *newObj)
{
    NSString* name = [self propNameFromSetterName:NSStringFromSelector(_cmd)];
    NSString* ivarName = [self ivarName:name];
    Ivar ivar = class_getInstanceVariable([self class], [ivarName UTF8String]);
    id oldObj = object_getIvar(self, ivar);
    if (![oldObj isEqual: newObj])
    {
        if(oldObj != nil)
            oldObj = nil;
        
        object_setIvar(self, ivar, newObj);
    }
}

+ (NSString*)setterName:(NSString*)name
{
    name = [self propName:name];
    
    NSRange r;
    r.length = name.length -1 ;
    r.location = 1;
    
    NSString* firstChar = [name stringByReplacingCharactersInRange:r withString:@""];
    
    r.length = 1;
    r.location = 0;
    
    NSString* theRest = [name stringByReplacingCharactersInRange:r withString:@""];
    
    return [NSString stringWithFormat:@"set%@%@", [firstChar uppercaseString] , theRest];
}



+ (NSString*)propNameFromSetterName:(NSString*)name
{
    NSRange r;
    r.length = 3 ;
    r.location = 0;
    
    NSString* propName = [name stringByReplacingCharactersInRange:r withString:@""];
    
    return [self propName:propName];
}

+ (NSString*)propName:(NSString*)name
{
    name = [name stringByReplacingOccurrencesOfString:@":" withString:@""];
    
    NSRange r;
    r.length = name.length -1 ;
    r.location = 1;
    
    NSString* firstChar = [name stringByReplacingCharactersInRange:r withString:@""];
    
    if([firstChar isEqualToString:[firstChar lowercaseString]])
    {
        return name;
    }
    
    r.length = 1;
    r.location = 0;
    
    NSString* theRest = [name stringByReplacingCharactersInRange:r withString:@""];
    
    return [NSString stringWithFormat:@"%@%@", [firstChar lowercaseString] , theRest];
}


+ (NSDictionary*)buildClassFromDictionary:(NSArray*)propNames withName:(NSString*)className
{
    NSMutableDictionary* keys = [[NSMutableDictionary alloc]init];
    
    Class newClass = NSClassFromString(className);
    
    if(newClass == nil) {
        
        newClass = objc_allocateClassPair([NSObject class], [className UTF8String], 0);
    
        for(NSString* key in propNames) {
            
            NSString* propName = [self propName: key];
            NSString* iVarName = [self ivarName:propName];
            
            class_addIvar(newClass, [iVarName UTF8String] , sizeof(NSObject*), log2(sizeof(NSObject*)), @encode(NSObject));
            
            objc_property_attribute_t a1 = { "T", "@\"NSObject\"" };
            objc_property_attribute_t a2 = { "&", "" };
            objc_property_attribute_t a3 = { "N", "" };
            objc_property_attribute_t a4 = { "V", [iVarName UTF8String] };
            
            objc_property_attribute_t attrs[] = { a1, a2, a3, a4};
            
            class_addProperty(newClass, [propName UTF8String], attrs, 4);
            class_addMethod(newClass, NSSelectorFromString(propName), (IMP)getter, "@@:");
            class_addMethod(newClass, NSSelectorFromString([self setterName:propName]), (IMP)setter, "v@:@");
            
            [keys setValue:key forKey:propName];
        }
        
        objc_registerClassPair(newClass);
    }
    
    return keys;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *dict = [IDYVideoManagerTableViewController buildClassFromDictionary:@[@"FirstName", @"LastName", @"Age", @"Gender",@"1234"] withName:@"Person"];
    NSLog(@"dict = %@",dict);
    
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return 0;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
