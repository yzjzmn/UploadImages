//
//  UploadManager.m
//  UploadImages
//
//  Created by yabei on 16/7/7.
//  Copyright © 2016年 com.bodi.merchant. All rights reserved.
//

#import "UploadManager.h"
#import "NSURLSessionWrapperOperation.h"
#import "AFNetworking.h"

@interface UploadManager ()
{
    NSMutableArray *imagesArr;
}
@end

@implementation UploadManager

//gcd上传
+ (void)commentReqWithImages:(NSArray *)imageArr
                      params:(NSMutableDictionary *)pramaDic
                     success:(void (^)(id JSON))success
                     failure:(void (^)(NSError *))failure
{
    
    dispatch_group_t group = dispatch_group_create();
    
    for (NSInteger i = 0; i < imageArr.count; i++) {
        
        dispatch_group_enter(group);
        
        NSURLSessionUploadTask* uploadTask = [UploadManager uploadTaskWithImage:imageArr[i] completion:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (error) {
                NSLog(@"第 %d 张图片上传失败: %@", (int)i + 1, error);
                dispatch_group_leave(group);
            } else {
//                @synchronized () {  NSMutableArray 是线程不安全的，所以加个同步锁
//                    
//                }
                
                //处理成功返回数据
                
                dispatch_group_leave(group);
            }
        }];
        [uploadTask resume];
    }
    
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        
        //图片上传之后的操作
        
    });

    
}


+ (void)uploadImagesWith:(NSArray *)images uploadFinish:(uploadCallBlock)finish success:(uploadSuccess)success failure:(uploadFailure)failure
{
    
//自己在处理operation上传多图的时候， 可能会出现bug   completionOperation在最后一个uploadOperation还没完成时就执行了   会导致少一张图    暂时没找到原因；希望有大神能够找出问题所在
//针对这个bug  我选择了  使用GCD替换NSOperation的方式 （GCD和NSOperation之间的优缺点比较就不提了）
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    queue.maxConcurrentOperationCount = 5;//control it yourself
    
    NSBlockOperation *completionOperation = [NSBlockOperation blockOperationWithBlock:^{
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{ // 回到主线程执行，方便更新 UI 等
            NSLog(@"上传完成!");
            
            finish();
            //all images had upload success
            
            //you can do next
            
        }];
    }];
    
    for (NSInteger i = 0; i < images.count; i++) {
        
        NSURLSessionUploadTask* uploadTask = [UploadManager uploadTaskWithImage:images[i] completion:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (error) {
                NSLog(@"第 %d 张图片上传失败: %@", (int)i + 1, error);
                failure(error, (int)i);
            } else {
                NSLog(@"第 %d 张图片上传成功: ", (int)i + 1);
                @synchronized (images) { // NSMutableArray 是线程不安全的，所以加个同步锁
                    
                    NSError *error = nil;
                    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&error];
                    NSDictionary *imgInfoDic = [dic objectForKey:@"data"];
                    
                    success(imgInfoDic, (int)i);
                    /**
                     *  这里有i这个参数  所以图片成功返回数据的先后顺序是有序的  怎么做靠你自己拉
                     */
                    
                }
            }
        }];
        
        //重写系统NSOperation 很关键  你可以直接copy
        NSURLSessionWrapperOperation *uploadOperation = [NSURLSessionWrapperOperation operationWithURLSessionTask:uploadTask];
        [completionOperation addDependency:uploadOperation];
        [queue addOperation:uploadOperation];
        
    }
    [queue addOperation:completionOperation];
    
}

#pragma mark - util

+ (NSURLSessionUploadTask*)uploadTaskWithImage:(UIImage *)image completion:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionBlock {
    
    @autoreleasepool {
        
        // 构造 NSURLRequest
        NSError* error = NULL;
        NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:@"you url" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            
            //转换data的方法 仅适用于😈楼主😈本人
//            NSData *imageData = [image imageByScalingToWithSize:PIC_MAX_WIDTH];
            
            NSData *imageData = UIImageJPEGRepresentation(image, 0.9);
            
            [formData appendPartWithFileData:imageData name:@"upload" fileName:@"upload.jpg" mimeType:@"image/jpeg"];
        } error:&error];
        
        // 将 NSURLRequest 与 completionBlock 包装为 NSURLSessionUploadTask
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        
        AFHTTPResponseSerializer *responseSerializer = manager.responseSerializer;
        
        NSMutableSet *contentTypes = [[NSMutableSet alloc] initWithSet:responseSerializer.acceptableContentTypes];
        [contentTypes addObject:@"text/html"];
        [contentTypes addObject:@"text/plain"];
        
        manager.responseSerializer = responseSerializer;
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithStreamedRequest:request progress:^(NSProgress * _Nonnull uploadProgress) {
        } completionHandler:completionBlock];
        
        return uploadTask;
        
    }
}

@end
