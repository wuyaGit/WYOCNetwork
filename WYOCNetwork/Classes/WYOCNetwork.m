//
//  WYOCNetwork.m
//  WYOCNetwork
//
//  Created by hero on 2018/11/6.
//  Copyright © 2018 Young Co., Ltd. All rights reserved.
//

#import "WYOCNetwork.h"
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/AFNetworkActivityIndicatorManager.h>

#ifdef DEBUG
#define WYLog(...) printf("[%s] %s [第%d行]: %s\n", __TIME__ ,__PRETTY_FUNCTION__ ,__LINE__, [[NSString stringWithFormat:__VA_ARGS__] UTF8String])

#else
#define WYLog(...)
#endif

static BOOL _openLog;
static NSMutableArray *_allSessionTask;
static AFHTTPSessionManager *_sessionManager;

@implementation WYOCNetwork

#pragma mark - 网络监测

/// 实时获取网络状态
+ (void)networkStatusWithBlock:(WYNetworkStatus)networkStatus {
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                networkStatus ? networkStatus(WYNetworkStatusUnknown) : nil;
                if (_openLog) {
                    WYLog(@"未知网络");
                }
                break;
            case AFNetworkReachabilityStatusNotReachable:
                networkStatus ? networkStatus(WYNetworkStatusNotReachable) : nil;
                if (_openLog) {
                    WYLog(@"无网络");
                }
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                networkStatus ? networkStatus(WYNetworkStatusReachableViaWWAN) : nil;
                if (_openLog) {
                    WYLog(@"手机网络");
                }
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                networkStatus ? networkStatus(WYNetworkStatusReachableViaWiFi) : nil;
                if (_openLog) {
                    WYLog(@"WiFi网络");
                }
                break;
            default:
                break;
        }
    }];
}

/// 是否有网络：YES，有网；NO，无网
+ (BOOL)isNetwork {
    return [AFNetworkReachabilityManager sharedManager].reachable;
}

#pragma mark - 打印日志（DEBUG）

/// 开启打印日志
+ (void)openLog {
    _openLog = YES;
}

/// 关闭打印日志，默认关闭
+ (void)closeLog {
    _openLog = NO;
}

#pragma mark - 取消请求

/// 取消指定url的HTTP请求
+ (void)cancelRequestWithUrl:(NSString *)url {
    if (!url) { return; }
    @synchronized (self) {
        [[self allSessionTask] enumerateObjectsUsingBlock:^(NSURLSessionTask  *_Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([task.currentRequest.URL.absoluteString hasPrefix:url]) {
                [task cancel];
                [[self allSessionTask] removeObject:task];
                *stop = YES;
            }
        }];
    }
}

/// 取消全部请求
+ (void)cancelAllRequest {
    // 锁操作
    @synchronized(self) {
        [[self allSessionTask] enumerateObjectsUsingBlock:^(NSURLSessionTask  *_Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            [task cancel];
        }];
        [[self allSessionTask] removeAllObjects];
    }
}

#pragma mark - 无缓存请求

/// GET请求无缓存
+ (NSURLSessionTask *)GET:(NSString *)url
               parameters:(id)parameters
                  success:(WYHttpRequestSuccess)success
                  failure:(WYHttpRequestFailed)failure {
   return [self GET:url parameters:parameters responseCache:nil success:success failure:failure];
}

/// POST请求无缓存
+ (NSURLSessionTask *)POST:(NSString *)url
                parameters:(id)parameters
                   success:(WYHttpRequestSuccess)success
                   failure:(WYHttpRequestFailed)failure {
    return [self POST:url parameters:parameters responseCache:nil success:success failure:failure];
}

#pragma mark - 有缓存请求

/// GET请求自动缓存
+ (NSURLSessionTask *)GET:(NSString *)url
               parameters:(id)parameters
            responseCache:(WYHttpRequestCache)responseCache
                  success:(WYHttpRequestSuccess)success
                  failure:(WYHttpRequestFailed)failure {
    //读取缓存
    responseCache ? responseCache([WYOCNetworkCache httpCacheForURL:url parameters:parameters]) : nil;
    
    NSURLSessionTask *task = [_sessionManager GET:url parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (_openLog) {
            WYLog(@"responseObject = %@",responseObject);
        }
        [[self allSessionTask] removeObject:task];

        if (success) {
            success([WYOCNetworkModel yy_modelWithJSON:responseObject]);
        }

        responseCache ? [WYOCNetworkCache setHttpCache:responseObject URL:url parameters:parameters] : nil;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (_openLog) {
            WYLog(@"error = %@",error);
        }
        
        [[self allSessionTask] removeObject:task];
        failure ? failure(error) : nil;
    }];
    
    // 添加sessionTask到数组
    task ? [[self allSessionTask] addObject:task] : nil;
    return task;
}

/// POST请求自动缓存
+ (NSURLSessionTask *)POST:(NSString *)url
                parameters:(id)parameters
             responseCache:(WYHttpRequestCache)responseCache
                   success:(WYHttpRequestSuccess)success
                   failure:(WYHttpRequestFailed)failure {
    //读取缓存
    responseCache ? responseCache([WYOCNetworkCache httpCacheForURL:url parameters:parameters]) : nil;
    
    NSURLSessionTask *task = [_sessionManager POST:url parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (_openLog) {
            WYLog(@"responseObject = %@",responseObject);
        }
        [[self allSessionTask] removeObject:task];

        if (success) {
            success([WYOCNetworkModel yy_modelWithJSON:responseObject]);
        }

        responseCache ? [WYOCNetworkCache setHttpCache:responseObject URL:url parameters:parameters] : nil;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (_openLog) {
            WYLog(@"error = %@",error);
        }
        
        [[self allSessionTask] removeObject:task];
        failure ? failure(error) : nil;
    }];
    
    // 添加sessionTask到数组
    task ? [[self allSessionTask] addObject:task] : nil;
    return task;
}

#pragma mark - 上传文件请求

+ (NSURLSessionTask *)uploadFileWithUrl:(NSString *)url
                             parameters:(id)parameters
                                   name:(NSString *)name
                               filePath:(NSString *)filePath
                               progress:(WYHttpProgress)progress
                                success:(WYHttpRequestSuccess)success
                                failure:(WYHttpRequestFailed)failure {
    NSURLSessionTask *task = [_sessionManager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSError *error = nil;
        [formData appendPartWithFileURL:[NSURL URLWithString:filePath] name:name error:&error];
        (failure && error) ? failure(error) : nil;
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        //上传进度
        dispatch_sync(dispatch_get_main_queue(), ^{
            progress ? progress(uploadProgress) : nil;
        });
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (_openLog) {
            WYLog(@"responseObject = %@",responseObject);
        }
        [[self allSessionTask] removeObject:task];

        if (success) {
            success([WYOCNetworkModel yy_modelWithJSON:responseObject]);
        }

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (_openLog) {
            WYLog(@"error = %@",error);
        }
        
        [[self allSessionTask] removeObject:task];
        failure ? failure(error) : nil;
    }];
    
    // 添加sessionTask到数组
    task ? [[self allSessionTask] addObject:task] : nil;
    return task;
}

#pragma mark - 上传图片请求

+ (NSURLSessionTask *)uploadImagesWithURL:(NSString *)url
                               parameters:(id)parameters
                                     name:(NSString *)name
                                   images:(NSArray<UIImage *> *)images
                                fileNames:(NSArray<NSString *> *)fileNames
                               imageScale:(CGFloat)imageScale
                                imageType:(NSString *)imageType
                                 progress:(WYHttpProgress)progress
                                  success:(WYHttpRequestSuccess)success
                                  failure:(WYHttpRequestFailed)failure {
    NSURLSessionTask *task = [_sessionManager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        for (NSUInteger i = 0; i < images.count; i++) {
            // 图片经过等比压缩后得到的二进制文件
            NSData *imageData = UIImageJPEGRepresentation(images[i], imageScale ?: 1.f);
            // 默认图片的文件名, 若fileNames为nil就使用
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyyMMddHHmmss";
            NSString *str = [formatter stringFromDate:[NSDate date]];
            NSString *imageFileName = [NSString stringWithFormat:@"%@%ld.%@",str,i,imageType?:@"jpg"];
            
            [formData appendPartWithFileData:imageData
                                        name:name
                                    fileName:fileNames ? [NSString stringWithFormat:@"%@.%@",fileNames[i],imageType?:@"jpg"] : imageFileName
                                    mimeType:[NSString stringWithFormat:@"image/%@",imageType ?: @"jpg"]];
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        //上传进度
        dispatch_sync(dispatch_get_main_queue(), ^{
            progress ? progress(uploadProgress) : nil;
        });
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (_openLog) {
            WYLog(@"responseObject = %@",responseObject);
        }
        [[self allSessionTask] removeObject:task];

        if (success) {
            success([WYOCNetworkModel yy_modelWithJSON:responseObject]);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (_openLog) {
            WYLog(@"error = %@",error);
        }
        
        [[self allSessionTask] removeObject:task];
        failure ? failure(error) : nil;
    }];
    
    // 添加sessionTask到数组
    task ? [[self allSessionTask] addObject:task] : nil ;
    
    return task;
}

#pragma mark - 下载请求

+ (NSURLSessionTask *)downloadWithURL:(NSString *)url
                              fileDir:(NSString *)fileDir
                             progress:(WYHttpProgress)progress
                              success:(void(^)(NSString *))success
                              failure:(WYHttpRequestFailed)failure {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    __block NSURLSessionDownloadTask *downloadTask = [_sessionManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        //下载进度
        dispatch_sync(dispatch_get_main_queue(), ^{
            progress ? progress(downloadProgress) : nil;
        });
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        //拼接缓存目录
        NSString *downloadDir = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:fileDir ? fileDir : @"Download"];
        //打开文件管理器
        NSFileManager *fileManager = [NSFileManager defaultManager];
        //创建Download目录
        [fileManager createDirectoryAtPath:downloadDir withIntermediateDirectories:YES attributes:nil error:nil];
        //拼接文件路径
        NSString *filePath = [downloadDir stringByAppendingPathComponent:response.suggestedFilename];
        //返回文件位置的URL路径
        return [NSURL fileURLWithPath:filePath];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        [[self allSessionTask] removeObject:downloadTask];
        if(failure && error) {failure(error) ; return ;};
        success ? success(filePath.absoluteString /** NSURL->NSString*/) : nil;
        
    }];
    //开始下载
    [downloadTask resume];
    // 添加sessionTask到数组
    downloadTask ? [[self allSessionTask] addObject:downloadTask] : nil ;
    
    return downloadTask;
}

#pragma mark - 设置AFHTTPSessionManager相关属性

+ (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field {
    [_sessionManager.requestSerializer setValue:value forHTTPHeaderField:field];
}

+ (void)setRequestTimeoutInterval:(NSTimeInterval)time {
    _sessionManager.requestSerializer.timeoutInterval = time;
}

+ (void)setSecurityPolicyWithCerPath:(NSString *)cerPath validatesDomainName:(BOOL)validatesDomainName {
    NSData *cerData = [NSData dataWithContentsOfFile:cerPath];
    // 使用证书验证模式
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    // 如果需要验证自建证书(无效证书)，需要设置为YES
    securityPolicy.allowInvalidCertificates = YES;
    // 是否需要验证域名，默认为YES;
    securityPolicy.validatesDomainName = validatesDomainName;
    securityPolicy.pinnedCertificates = [[NSSet alloc] initWithObjects:cerData, nil];
    
    [_sessionManager setSecurityPolicy:securityPolicy];
}

#pragma mark - initialize

+ (void)load {
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

+ (void)initialize {
    _sessionManager = [AFHTTPSessionManager manager];
    _sessionManager.requestSerializer.timeoutInterval = 20.f;
    _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", @"text/json", @"text/plain", @"text/javascript", @"text/xml", @"image/*", nil];
    // 打开状态栏的等待菊花
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
}

#pragma mark - getter & setter

+ (NSMutableArray *)allSessionTask {
    if (_allSessionTask) {
        _allSessionTask = [[NSMutableArray alloc] init];
    }
    return _allSessionTask;
}

@end
