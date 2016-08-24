//
//  PHAssetViewController.m
//  UploadImages
//
//  Created by yabei on 16/7/7.
//  Copyright © 2016年 com.bodi.merchant. All rights reserved.
//

#import "PHAssetViewController.h"

#import <Photos/Photos.h>
#import "UploadManager.h"

@interface PHAssetViewController ()
{
    PHAsset *phasset;
}

@end

@implementation PHAssetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    //系统 8.0之后 推出了  PHAsset取代ALAsset  PHAsset也有很多坑，具体的可以看我写的相册库（YZJPhotos）
    
    //推荐文章:讲的差不多了  http://objccn.io/issue-21-4/
    
    //顺便说一下  如果你打开了上述网址,相信你会学习网站上其他知识的
    
    //ok,  UploadManager来上传 50张图片吧   NSURLSessionWrapperOperation这个类是关键,这个写的很粗糙  你可以给 UploadManager加以延伸
    
    [self getImageBy:phasset];
    
    NSArray *imagesArr;
    
    [UploadManager uploadImagesWith:imagesArr uploadFinish:^{
        //all pic success
    } success:^(NSDictionary *imgDic, int idx) {
        //imagesArr[i] success return imgDic
    } failure:^(NSError *error, int idx) {
        //imagesArr[i] failure
        //你可以自己处理失败 如果终止网络  (queue cancleAllOperation)
    }];
}

- (UIImage *)getImageBy:(PHAsset *)asset
{
    __block UIImage *image = nil;
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    
    //同步获取图片,只会返回1张图
    options.synchronous = YES;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    
    CGFloat W = asset.pixelWidth;
    CGFloat H = asset.pixelHeight;
    
    CGSize assetSize = CGSizeMake(W, H);//这个参数是取原尺寸的， 展示的时候一般不取原尺寸
    
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:assetSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
        
        image = result;
        
    }];
    
    return image;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
