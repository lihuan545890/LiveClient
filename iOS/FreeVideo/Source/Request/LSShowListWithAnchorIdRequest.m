//
// LSShowListWithAnchorIdRequest.m
//  dating
//
//  Created by Max on 18/04/27.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "LSShowListWithAnchorIdRequest.h"

@implementation LSShowListWithAnchorIdRequest
- (instancetype)init{
    if (self = [super init]) {
        self.sortType = SHOWRECOMMENDLISTTYPE_UNKNOW;
        self.start = 0;
        self.step = 0;
        self.anchorId = @"";
    }
    
    return self;
}

- (void)dealloc {
    
}

- (BOOL)sendRequest {
    if( self.manager ) {
        __weak typeof(self) weakSelf = self;
        NSInteger request = [self.manager showListWithAnchorId:self.anchorId start:self.start step:self.step sortType:self.sortType finishHandler:^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSArray<LSProgramItemObject *> * _Nullable array) {
            BOOL bFlag = NO;

            // 没有处理过, 才进入LSSessionRequestManager处理
            if( !weakSelf.isHandleAlready && weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(request:handleRespond:errnum:errmsg:)] ) {
                bFlag = [self.delegate request:weakSelf handleRespond:success errnum:errnum errmsg:errmsg];
                weakSelf.isHandleAlready = YES;
            }

            if( !bFlag && weakSelf.finishHandler ) {
                weakSelf.finishHandler(success, errnum, errmsg, array);
                [weakSelf finishRequest];
            }
        }];
        return request != 0;
    }
    return NO;
}

- (void)callRespond:(BOOL)success errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString* _Nullable)errmsg {
    if( self.finishHandler && !success ) {
        NSMutableArray *array = [NSMutableArray copy];
        self.finishHandler(NO, errnum, errmsg, array);
    }
    
    [super callRespond:success errnum:errnum errmsg:errmsg];
}

@end
