//
//  WYOCNetworkModel.h
//  WYOCNetwork
//
//  Created by hero on 2018/11/7.
//

#import <Foundation/Foundation.h>
#import <YYModel/YYModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface WYOCNetworkModel : NSObject <YYModel>

/// 返回码
@property (nonatomic, assign) NSInteger code;
/// 返回数据
@property (nonatomic, strong) id data;
/// 提示信息
@property (nonatomic, copy) NSString *msg;

@end

NS_ASSUME_NONNULL_END
