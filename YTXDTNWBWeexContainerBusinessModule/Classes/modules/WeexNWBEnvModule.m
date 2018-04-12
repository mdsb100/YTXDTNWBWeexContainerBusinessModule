//
//  WeexNWBEnvModule.m
//  YTXDTNWBWeexContainerBusinessModule
//
//  Created by 李龙龙 on 2018/2/8.
//

#import "WeexNWBEnvModule.h"
#import <WeexSDK/WeexSDK.h>
#import "YTXDTNWBWeexContainerBusinessModule-Swift.h"

@implementation WeexNWBEnvModule

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

WX_EXPORT_METHOD_SYNC(@selector(isTest))

WX_EXPORT_METHOD_SYNC(@selector(getVersionName))

WX_EXPORT_METHOD_SYNC(@selector(getVersionCode))

WX_EXPORT_METHOD_SYNC(@selector(getSdkVersion))

WX_EXPORT_METHOD_SYNC(@selector(getAppId))

WX_EXPORT_METHOD_SYNC(@selector(getChannelId))

WX_EXPORT_METHOD_SYNC(@selector(getClientType))

WX_EXPORT_METHOD_SYNC(@selector(getDeviceToken))

WX_EXPORT_METHOD_SYNC(@selector(getAll))

#pragma clang diagnostic pop

@end
