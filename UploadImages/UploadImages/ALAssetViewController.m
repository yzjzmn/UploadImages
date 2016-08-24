//
//  ALAssetViewController.m
//  UploadImages
//
//  Created by yabei on 16/7/7.
//  Copyright © 2016年 com.bodi.merchant. All rights reserved.
//

#import "ALAssetViewController.h"

#import <AssetsLibrary/AssetsLibrary.h>

@interface ALAssetViewController ()

@end

@implementation ALAssetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#pragma clang diagnostic ignored "-Wunused-variable"
    /**
     *  ALAsset遇到的问题:
     *
     *  @return 网上有很多用ALAsset创建的多选相册库,但是很多都不完善,主要说一下我遇到的问题
     */
    
    //1.一般多选相册会回掉给你一个数组,数组里有asset对象(或者是第三方代码写的model,model的属性为asset),我们拿到asset之后用来加载图片
    
    ALAsset *asset;
    
    UIImage *img = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullResolutionImage] scale:1.0 orientation:UIImageOrientationUp];
    
    //[asset aspectRatioThumbnail]   按原始资源长宽比例的缩略图
    //[asset thumbnail]              缩略图                    一般用去较小控件显示
    //fullScreenImage                全屏图                    和 fullResolutionImage 要重点区分
    //fullResolutionImage            全尺寸图                  一般我们要很使用的是这个
    
    //*前两个缩略图就不说了  不论你回调之后展示的是哪一个  上传的时候 都会用全尺寸图
    
    //*😳*不过建议展示UI的时候这样做  省内存别问为什么
    
    NSURL *imgUrl = [[asset defaultRepresentation] url];
    
    UIImage *image = [UIImage imageWithContentsOfFile:[NSString stringWithContentsOfURL:imgUrl]];
    
    //2.图片被旋转90°(个别图片 大小大于2M的 ,网上说的五花八门,这个2M不是确定数值)
    
    //首先,看下这篇文章  http://www.cocoachina.com/ios/20150605/12021.html
    
    // so   orientation 这个属性控制照片的朝向的  但你发现 你设置UIImageOrientationUp并没有卵用
    
    //其实坑在这里  一开始 我以为 scale 设置为1.0就应该是原图比例了   其实不是这样的,所以获取一张原图应该这样写:
    UIImage *img1 = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullResolutionImage] scale:[[asset defaultRepresentation] scale] orientation:UIImageOrientationUp];
    //获取图片本身的比例 设置给他
    
    
    //3.最重要的 fullScreenImage 和 fullResolutionImage 区别
    
    //其实第二个问题,如果你是用了fullScreenImage  就不会遇到了,但是这样你获取的就是全屏图,并不是原图,所以一定要注意
    
    //因为fullResolutionImage 有可能太大了,推荐使用 fullScreenImage来展示UI(如果你需要的话)
    
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
