//
//  AcceptInstanceInviteRequest.m
//  dating
//
//  Created by Alex on 18/9/28.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "LSGetPushConfigRequest.h"

@implementation LSGetPushConfigRequest
- (instancetype)init{
    if (self = [super init]) {
    }
    
    return self;
}

- (void)dealloc {
    
}

- (BOOL)sendRequest {
    if( self.manager ) {
        __weak typeof(self) weakSelf = self;
        NSInteger request = [self.manager getPushConfig:^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, BOOL isPriMsgAppPush, BOOL isMailAppPush) {
            BOOL bFlag = NO;
            
            // 没有处理过, 才进入LSSessionRequestManager处理
            if( !weakSelf.isHandleAlready && weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(request:handleRespond:errnum:errmsg:)] ) {
                bFlag = [self.delegate request:weakSelf handleRespond:success errnum:errnum errmsg:errmsg];
                weakSelf.isHandleAlready = YES;
            }
            
            if( !bFlag && weakSelf.finishHandler ) {
                weakSelf.finishHandler(success, errnum, errmsg, isPriMsgAppPush, isMailAppPush);
                [weakSelf finishRequest];
            }
        }];
        return request != 0;
    }
    return NO;
}

- (void)callRespond:(BOOL)success errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString* _Nullable)errmsg {
    if( self.finishHandler && !success ) {
        self.finishHandler(NO, errnum, errmsg, NO, NO);
    }
    
    [super callRespond:success errnum:errnum errmsg:errmsg];
}

@end