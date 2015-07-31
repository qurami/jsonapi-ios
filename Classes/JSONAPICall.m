//
//  JSONAPICall.m
//  JSONAPI
//
//  Created by Marco Musella on 30/07/15.
//  Copyright (c) 2015 Josh Holtz. All rights reserved.
//

#import "JSONAPICall.h"
#import "JSONAPIDocument.h"

@interface JSONAPICall (){
    
    void (^_completionHandler)(JSONAPIDocument *jsonApiDocument, NSInteger statusCode);
    void (^_failureHandler)(NSError *error);
    
    
    NSString *_HTTPMethod;
    NSMutableDictionary *_additionalHTTPHeaders;
    NSString *_apiPath;
    NSURL *_requestUrl;
    NSString *_requestBody;
    
    NSMutableData *_requestReceivedData;
    
    NSURLSession *_urlSession;

}

@end

@implementation JSONAPICall


- (void) getJSONAPIWithPath: (NSString *) path completionHandler:(void (^)(JSONAPIDocument *jsonApi, NSInteger statusCode))completionHandler failureHandler:(void (^)(NSError *error))failureHandler{

    [self getJSONAPIWithPath: path includedResourceTypes: nil completionHandler: completionHandler failureHandler: failureHandler];
    
}

- (void) getJSONAPIWithPath: (NSString *) path includedResourceTypes: (NSArray *) includedResourceTypes completionHandler:(void (^)(JSONAPIDocument *jsonApi, NSInteger statusCode))completionHandler failureHandler:(void (^)(NSError *error))failureHandler{
    
    _HTTPMethod = @"POST";
    _includedResources = includedResourceTypes;
    _completionHandler = completionHandler;
    _failureHandler = failureHandler;
    _apiPath = path;
    
    [self startApiCall];
}


- (void) startApiCall{

    [self buildHeaders];
    [self buildURL];
    [self configureSession];
    [self startSession];

}

- (void) buildURL{
    
    NSString *urlString = [_endpoint stringByAppendingPathComponent: _apiPath];
    
    if(_includedResources){
        NSString *elements = [_includedResources componentsJoinedByString:@","];
        urlString = [urlString stringByAppendingString:[NSString stringWithFormat:@"?include=%@", elements]];
    }
    
    _requestUrl = [NSURL URLWithString: urlString];
}

- (void) buildHeaders{
    
    
    NSDictionary *jsonAPIHTTPHeaders = @{
                                         @"Content-Type" : @"application/vnd.api+json",
                                         @"Accept" : @"application/vnd.api+json"
                                             };
    
    [self appendAdditionalHTTPHeaders: jsonAPIHTTPHeaders];

}

- (void) appendAdditionalHTTPHeaders: (NSDictionary *) additionalHeaders{

    if(!_additionalHTTPHeaders)
        _additionalHTTPHeaders = [NSMutableDictionary new];
    
    [_additionalHTTPHeaders addEntriesFromDictionary: additionalHeaders];

}

- (void) configureSession{
    
    if(!_sessionConfiguration){
        _sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    }
    
    [_sessionConfiguration setHTTPAdditionalHeaders: _additionalHTTPHeaders];
    
    _urlSession = [NSURLSession sessionWithConfiguration: _sessionConfiguration delegate: self delegateQueue:[NSOperationQueue mainQueue]];
}

- (void) startSession{

    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL: _requestUrl];
    [req setHTTPMethod: _HTTPMethod];
    [req setHTTPBody: [_requestBody dataUsingEncoding:NSUTF8StringEncoding]];
    _requestReceivedData = nil;
    
    NSLog(@"%@ : session starting with http headers \n %@", NSStringFromClass([self class]), _urlSession.configuration.HTTPAdditionalHeaders);
    NSLog(@"%@ : for apirequest with url %@", NSStringFromClass([self class]), [_requestUrl absoluteString]);
    
    [[_urlSession dataTaskWithRequest: req] resume];

}

#pragma mark - NSURLSessionDelegate & NSURLSessionTaskDelegate

- (void) URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    
    if(!_requestReceivedData)
        _requestReceivedData = [NSMutableData new];
    
    [_requestReceivedData appendData: data];
    
}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    
    NSInteger statusCode = [(NSHTTPURLResponse *)task.response statusCode];
    
    if(error){
        
        NSLog(@"%@ : url session failed with error: %@", NSStringFromClass([self class]), error.localizedDescription);

        if(_failureHandler)
            _failureHandler(error);
    }
    else{
        
        NSString *mimeType = task.response.MIMEType;
        
        if([mimeType containsString:@"application/vnd.api+json"])
            [self jsonApiCallCompletedWithData: _requestReceivedData statusCode: statusCode];
        else{
            NSDictionary *userInfo = @{
                                       NSLocalizedDescriptionKey: @"bad response",
                                       NSLocalizedFailureReasonErrorKey: @"MIME Type was not application/vnd.api+json",
                                       NSLocalizedRecoverySuggestionErrorKey: @"for further information: http://jsonapi.org"
                                       };
            
            NSError *mimeTypeError = [NSError errorWithDomain:@"JSONAPIErrorDomain" code:-415 userInfo:userInfo];
            _failureHandler(mimeTypeError);
        
        }
    }
    
    
    [session invalidateAndCancel];
}



- (void) URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler{
    
    NSInteger authChallangeCount = challenge.previousFailureCount;
    
    if(authChallangeCount == 0){
        completionHandler(NSURLSessionAuthChallengeUseCredential, _sessionCredential);
    }
    else
        completionHandler(NSURLSessionAuthChallengeRejectProtectionSpace, nil);
    
    
}

#pragma mark - Callbacks

- (void) jsonApiCallCompletedWithData: (NSData *) data statusCode: (NSInteger) statusCode{
    
    NSString *jsonDataString = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    
    JSONAPIDocument *jsonApiDocument = [JSONAPIDocument jsonAPIWithString: jsonDataString];
    
    if(_completionHandler)
        _completionHandler(jsonApiDocument, statusCode);
    
}


@end
