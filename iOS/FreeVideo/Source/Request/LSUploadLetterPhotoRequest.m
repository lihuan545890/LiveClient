//
//  LSUploadLetterPhotoRequest.m
//  dating
//
//  Created by Alex on 17/9/11.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSUploadLetterPhotoRequest.h"

@implementation LSUploadLetterPhotoRequest
- (instancetype)init{
    if (self = [super init]) {
        self.file = @"";
        self.fileName = @"";
    }
    
    return self;
}

- (void)dealloc {
    
}

- (BOOL)sendRequest {
    if( self.manager ) {
        __weak typeof(self) weakSelf = self;
        NSInteger request = [self.manager uploadLetterPhoto:self.fileName file:self.file finishHandler:^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSString *url, NSString *md5, NSString *  fileName) {
            BOOL bFlag = NO;
            
            // 没有处理过, 才进入LSSessionRequestManager处理
            if( !weakSelf.isHandleAlready && weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(request:handleRespond:errnum:errmsg:)] ) {
                bFlag = [self.delegate request:weakSelf handleRespond:success errnum:errnum errmsg:errmsg];
                weakSelf.isHandleAlready = YES;
            }
            
            if( !bFlag && weakSelf.finishHandler ) {
                weakSelf.finishHandler(success, errnum, errmsg, url, md5, fileName);
                [weakSelf finishRequest];
            }
        }];
        return request != 0;
    }
    return NO;
}

- (void)callRespond:(BOOL)success errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString* _Nullable)errmsg {
    if( self.finishHandler && !success ) {
        self.finishHandler(NO, errnum, errmsg, @"", @"", @"");
    }
    
    [super callRespond:success errnum:errnum errmsg:errmsg];
}

@end
