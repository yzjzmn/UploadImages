//
//  ViewController.m
//  UploadImages
//
//  Created by 杨镇江 on 16/8/24.
//  Copyright © 2016年 yzj. All rights reserved.
//

#import "ViewController.h"

#import "PHAssetViewController.h"
#import "ALAssetViewController.h"
#import "JXTAlertTools.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITableView *myTable;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _myTable.tableFooterView = [UIView new];
    
    //分享个别人的东西 alertView actionSheet 与 alertController的兼容
    //同时把之前的delegate模式封装成block了
    //具体用法自己去看吧
    //哈哈，我还给这个JXTAlertTools提过bug呢
    
    typeof(self) __weak weakSelf = self;
    [JXTAlertTools showAlertWith:self title:@"给大家分享自己的经验" message:@"哪里不对的话请给我指正" callbackBlock:^(NSInteger btnIndex) {
        //回调的方法
        
        switch (btnIndex) {
            case 0:
                NSLog(@"0默认是取消按钮");
                [weakSelf interesting];
                break;
                
            case 1:
                NSLog(@"你点了第%ld个按钮", (long)btnIndex);
                [weakSelf interesting];
                break;
                
            default:
                break;
        }
        
    } cancelButtonTitle:@"取消啊" destructiveButtonTitle:nil otherButtonTitles:@"确定啦", nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)interesting
{
    NSArray * titles = @[@"QQ:86985379", @"微信:jiang86985379", @"我只是大自然的搬运工"];
    NSArray * styles = @[
                         [NSNumber numberWithInteger:JXTAlertActionStyleDefault],
                         [NSNumber numberWithInteger:JXTAlertActionStyleDefault],
                         [NSNumber numberWithInteger:JXTAlertActionStyleDestructive],
                         ];
    
    [JXTAlertTools showArrayActionSheetWith:[JXTAlertTools activityViewController] title:@"再来个actionSheet" message:@"yzj" callbackBlock:^(NSInteger btnIndex) {
        switch (btnIndex) {
            case 0:
                NSLog(@"0默认是取消按钮");
                break;
                
            case 1:
                NSLog(@"你点了第%ld个按钮", (long)btnIndex);
                break;
                
            case 2:
                NSLog(@"你点了第%ld按钮", btnIndex);
                break;
                
            case 3:
                NSLog(@"你点了第%ld按钮", btnIndex);
                break;
                
                
            default:
                break;
        }
    } cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitleArray:titles otherButtonStyleArray:styles];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"ALAsset";
    }
    
    if (indexPath.row == 1) {
        cell.textLabel.text = @"PHAsset";
    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIViewController *vc;
    
    if (indexPath.row == 0) {
        
        vc = [ALAssetViewController new];
        
    }
    if (indexPath.row == 1) {
        
        vc = [PHAssetViewController new];
        
    }
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

@end
