//
//  WYOCNetwork.h
//  WYOCNetwork
//
//  Created by hero on 2018/11/6.
//  Copyright © 2018 Young Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WYOCNetworkCache.h"
#import "WYOCNetworkModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, WYNetworkStatusType) {
    /// 未知
    WYNetworkStatusUnknown,
    /// 无网络
    WYNetworkStatusNotReachable,
    /// 手机网络
    WYNetworkStatusReachableViaWWAN,
    /// WiFi网络
    WYNetworkStatusReachableViaWiFi
};

/// 网络状态block
typedef void (^WYNetworkStatus)(WYNetworkStatusType status);
/// 请求成功block
typedef void (^WYHttpRequestSuccess)(WYOCNetworkModel *responseObject);
/// 请求失败block
typedef void (^WYHttpRequestFailed)(NSError *error);
/// 请求缓存block
typedef void (^WYHttpRequestCache)(id responseCache);
/// 上传或下载进度 Progress.completedUnitCount:当前大小 - Progress.totalUnitCount:总大小
typedef void (^WYHttpProgress)(NSProgress *progress);

@interface WYOCNetwork : NSObject

#pragma mark - 网络监测

/// 实时获取网络状态
+ (void)networkStatusWithBlock:(WYNetworkStatus)networkStatus;

/// 是否有网络：YES，有网；NO，无网
+ (BOOL)isNetwork;

#pragma mark - 打印日志（DEBUG）

/// 开启打印日志
+ (void)openLog;

/// 关闭打印日志，默认关闭
+ (void)closeLog;

#pragma mark - 取消请求

/// 取消指定url的HTTP请求
+ (void)cancelRequestWithUrl:(NSString *)url;

/// 取消全部请求
+ (void)cancelAllRequest;

#pragma mark - 无缓存请求

/**
 * GET请求无缓存
 */
+ (__kindof NSURLSessionTask *)GET:(NSString *_Nonnull)url
               parameters:(nullable id)parameters
                  success:(nullable WYHttpRequestSuccess)success
                  failure:(nullable WYHttpRequestFailed)failure;

/**
 * POST请求无缓存
 */
+ (__kindof NSURLSessionTask *)POST:(NSString *_Nonnull)url
                parameters:(nullable id)parameters
                   success:(nullable WYHttpRequestSuccess)success
                   failure:(nullable WYHttpRequestFailed)failure;
#pragma mark - 有缓存请求

/**
 * GET请求自动缓存
 */
+ (__kindof NSURLSessionTask *)GET:(NSString *_Nonnull)url
               parameters:(nullable id)parameters
            responseCache:(nullable WYHttpRequestCache)responseCache
                  success:(nullable WYHttpRequestSuccess)success
                  failure:(nullable WYHttpRequestFailed)failure;

/**
 * POST请求自动缓存
 */
+ (__kindof NSURLSessionTask *)POST:(NSString *_Nonnull)url
                parameters:(nullable id)parameters
             responseCache:(nullable WYHttpRequestCache)responseCache
                   success:(nullable WYHttpRequestSuccess)success
                   failure:(nullable WYHttpRequestFailed)failure;

#pragma mark - 上传文件请求
/**
 *  上传文件
 *
 *  @param url        请求地址
 *  @param parameters 请求参数
 *  @param name       文件对应服务器上的字段
 *  @param filePath   文件本地的沙盒路径
 *  @param progress   上传进度信息
 *  @param success    请求成功的回调
 *  @param failure    请求失败的回调
 *
 *  @return 返回的对象可取消请求,调用cancel方法
 */
+ (__kindof NSURLSessionTask *)uploadFileWithUrl:(NSString *_Nonnull)url
                             parameters:(nullable id)parameters
                                   name:(nullable NSString *)name
                               filePath:(nullable NSString *)filePath
                               progress:(nullable WYHttpProgress)progress
                                success:(nullable WYHttpRequestSuccess)success
                                failure:(nullable WYHttpRequestFailed)failure;

#pragma mark - 上传图片请求

/**
 *  上传单/多张图片
 *
 *  @param url        请求地址
 *  @param parameters 请求参数
 *  @param name       图片对应服务器上的字段
 *  @param images     图片数组
 *  @param fileNames  图片文件名数组, 可以为nil, 数组内的文件名默认为当前日期时间"yyyyMMddHHmmss"
 *  @param imageScale 图片文件压缩比 范围 (0.f ~ 1.f)
 *  @param imageType  图片文件的类型,例:png、jpg(默认类型)....
 *  @param progress   上传进度信息
 *  @param success    请求成功的回调
 *  @param failure    请求失败的回调
 *
 *  @return 返回的对象可取消请求,调用cancel方法
 */
+ (__kindof NSURLSessionTask *)uploadImagesWithURL:(NSString *_Nonnull)url
                               parameters:(nullable id)parameters
                                     name:(nullable NSString *)name
                                   images:(nullable NSArray<UIImage *> *)images
                                fileNames:(nullable NSArray<NSString *> *)fileNames
                               imageScale:(CGFloat)imageScale
                                imageType:(nullable NSString *)imageType
                                 progress:(nullable WYHttpProgress)progress
                                  success:(nullable WYHttpRequestSuccess)success
                                  failure:(nullable WYHttpRequestFailed)failure;

#pragma mark - 下载请求

/**
 *  下载文件
 *
 *  @param url      请求地址
 *  @param fileDir  文件存储目录(默认存储目录为Download)
 *  @param progress 文件下载的进度信息
 *  @param success  下载成功的回调(回调参数filePath:文件的路径)
 *  @param failure  下载失败的回调
 *
 *  @return 返回NSURLSessionDownloadTask实例，可用于暂停继续，暂停调用suspend方法，开始下载调用resume方法
 */
+ (__kindof NSURLSessionTask *)downloadWithURL:(NSString *_Nonnull)url
                              fileDir:(nullable NSString *)fileDir
                             progress:(nullable WYHttpProgress)progress
                              success:(nullable void(^)(NSString *))success
                              failure:(nullable WYHttpRequestFailed)failure;

#pragma mark - 设置AFHTTPSessionManager相关属性

/**
 *  设置请求超时时间:默认为20S
 *
 *  @param time 时长
 */
+ (void)setRequestTimeoutInterval:(NSTimeInterval)time;

/**
 配置自建证书的Https请求, 参考链接: http://blog.csdn.net/syg90178aw/article/details/52839103
 
 @param cerPath 自建Https证书的路径
 @param validatesDomainName 是否需要验证域名，默认为YES. 如果证书的域名与请求的域名不一致，需设置为NO; 即服务器使用其他可信任机构颁发
 的证书，也可以建立连接，这个非常危险, 建议打开.validatesDomainName=NO, 主要用于这种情况:客户端请求的是子域名, 而证书上的是另外
 一个域名。因为SSL证书上的域名是独立的,假如证书上注册的域名是www.google.com, 那么mail.google.com是无法验证通过的.
 */
+ (void)setSecurityPolicyWithCerPath:(NSString *)cerPath validatesDomainName:(BOOL)validatesDomainName;

@end

NS_ASSUME_NONNULL_END
