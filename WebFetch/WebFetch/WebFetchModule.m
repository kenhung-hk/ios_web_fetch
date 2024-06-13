//
//  WebFetchModule.m
//  WebFetch
//
//  Created by Ken on 13/6/2024.
//

#ifndef WebFetchModule_h
#define WebFetchModule_h


#endif /* WebFetchModule_h */
// WebFetchModule.m
#import "WebFetchModule.h"

@implementation WebFetchModule

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(performFetch:(NSString *)url
                  method:(NSString *)method
                  headers:(NSDictionary *)headers
                  body:(NSString *)body
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    WebFetch *webFetch = [[WebFetch alloc] init];
    [webFetch performFetchWithUrl:url method:method headers:headers body:body completion:^(NSError *error, NSString *result) {
        if (error) {
            reject(@"fetch_error", error.localizedDescription, error);
        } else {
            resolve(result);
        }
    }];
}

@end
