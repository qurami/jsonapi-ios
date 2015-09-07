//
//  JSONAPICall.m
//  JSONAPI
//
//  Created by Marco Musella on 30/07/15.
//  Copyright (c) 2015 Josh Holtz. All rights reserved.
//

#import "JSONAPIClient.h"
#import "JSONAPIDocument.h"
#import "JSONAPIJSONEncoder.h"


NSString *const JSONAPIClientErrorDomain = @"JSONAPIClientErrorDomain";


@interface JSONAPIClient (){
    
    void (^_completionHandler)(JSONAPIDocument *jsonApiDocument, NSInteger statusCode, NSError *error);
    
    
    NSString *_HTTPMethod;
    NSMutableDictionary *_additionalHTTPHeaders;
    NSString *_apiPath;
    NSURL *_requestUrl;
    NSString *_requestBody;
    NSArray *_includedResources;
    
    NSMutableData *_requestReceivedData;
    NSInteger _requestReceivedStatusCode;
    
    NSURLSession *_urlSession;

}

@end

@implementation JSONAPIClient

#pragma mark - HTTPMethods

- (void) getJSONAPIDocumentWithPath: (NSString *) path completionHandler:(void (^)(JSONAPIDocument *jsonApi, NSInteger statusCode, NSError *error))completionHandler{

    [self getJSONAPIDocumentWithPath: path includedResourceTypes: nil completionHandler: completionHandler];
    
}

- (void) getJSONAPIDocumentWithPath: (NSString *) path includedResourceTypes: (NSArray *) includedResourceTypes completionHandler:(void (^)(JSONAPIDocument *jsonApi, NSInteger statusCode, NSError *error))completionHandler{
    
    _HTTPMethod = @"GET";
    _includedResources = includedResourceTypes;
    _completionHandler = completionHandler;
    _apiPath = path;
    
    [self startApiCall];
}

- (void) postJSONAPIDocument: (JSONAPIDocument *) documentToPost withPath: (NSString *) path completionHandler: (void(^)(JSONAPIDocument *jsonApiDocument, NSInteger statusCode, NSError *error)) completionHandler{


    [self postJSONAPIDocument: documentToPost withPath: path includedResources: nil completionHandler: completionHandler];
    
}

- (void) postJSONAPIDocument: (JSONAPIDocument *) documentToPost withPath: (NSString *) path includedResources: (NSArray *) includedResourceTypes completionHandler: (void(^)(JSONAPIDocument *jsonApiDocument, NSInteger statusCode, NSError *error)) completionHandler{

    
    _HTTPMethod = @"POST";
    _includedResources = includedResourceTypes;
    _completionHandler = completionHandler;
    _apiPath = path;
    _requestBody = [JSONAPIJSONEncoder jsonEncodedStringForJSONAPIDocument: documentToPost];
    
    [self startApiCall];
    

}


- (void) deleteJSONAPIResourceWithPath: (NSString *) path completionHandler: (void(^)(JSONAPIDocument *jsonApiDocument ,NSInteger statusCode, NSError *error)) completionHandler{
    
    _HTTPMethod = @"DELETE";
    _includedResources = nil;
    _apiPath = path;
    _requestBody = nil;
    _completionHandler = completionHandler;
    
    [self startApiCall];

}




#pragma mark - API Call

- (void) startApiCall{

    [self buildHeaders];
    [self buildURL];
    [self configureSession];
    [self startSession];

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


- (void) buildURL{
    
    NSString *urlString = [_endpoint stringByAppendingPathComponent: _apiPath];
    
    if(_includedResources){
        NSString *elements = [_includedResources componentsJoinedByString:@","];
        urlString = [urlString stringByAppendingString:[NSString stringWithFormat:@"?include=%@", elements]];
    }
    
    _requestUrl = [NSURL URLWithString: urlString];
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
    
    //workaround to fix a bug on iOS 8.3 where content type was overridden.
    [req setValue:@"application/vnd.api+json"  forHTTPHeaderField:@"Content-Type"];
    [req setHTTPMethod: _HTTPMethod];
    [req setHTTPBody: [_requestBody dataUsingEncoding:NSUTF8StringEncoding]];
    _requestReceivedData = nil;
    
    
    NSLog(@"%@ : session starting with http headers \n %@", NSStringFromClass([self class]), _urlSession.configuration.HTTPAdditionalHeaders);
    NSLog(@"%@ : for apirequest with url %@", NSStringFromClass([self class]), [_requestUrl absoluteString]);
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: YES];
    
    [[_urlSession dataTaskWithRequest: req] resume];

}

#pragma mark - NSURLSessionDelegate & NSURLSessionTaskDelegate

- (void) URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    
    if(!_requestReceivedData)
        _requestReceivedData = [NSMutableData new];
    
    [_requestReceivedData appendData: data];
    
}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
    _requestReceivedStatusCode = [(NSHTTPURLResponse *)task.response statusCode];

    if(error){
        NSLog(@"%@ : url session failed with error: %@", NSStringFromClass([self class]), error.localizedDescription);
        [self returnCallbackWithError: error];
    }
    else{

        NSString *mimeType = task.response.MIMEType;
        BOOL isJSONAPIMimeType = [mimeType  rangeOfString:@"application/vnd.api+json"].location != NSNotFound;
        
        if(isJSONAPIMimeType || _requestReceivedStatusCode == 204){
            [self jsonApiCallCompletedWithData: _requestReceivedData statusCode: _requestReceivedStatusCode];
        }
        else{
            [self returnCallbackWithError:[self mimetypeError]];
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
    
    
    if(statusCode == 204){
        _completionHandler(nil, statusCode, nil);
    }
    else{
        
        NSString *jsonDataString = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
        JSONAPIDocument *jsonApiDocument = [JSONAPIDocument jsonAPIDocumentWithString: jsonDataString];
        
        if(!jsonApiDocument)
            [self returnCallbackWithError: [self malformedDataError]];
        
        else{
            if(_completionHandler)
                _completionHandler(jsonApiDocument, statusCode, nil);
        }
        
    
    }
    
}

- (NSError *) malformedDataError{
    
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: @"bad response",
                               NSLocalizedFailureReasonErrorKey: @"Unable to parse json data into JSONAPIDocument",
                               NSLocalizedRecoverySuggestionErrorKey: @"for further information: http://jsonapi.org"
                               };
    
    NSError *malformedDataError = [NSError errorWithDomain:JSONAPIClientErrorDomain code:kMalformedContentError userInfo:userInfo];

    return malformedDataError;
    
}

- (NSError *) mimetypeError{
    
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: @"bad response",
                               NSLocalizedFailureReasonErrorKey: @"MIME Type was not application/vnd.api+json",
                               NSLocalizedRecoverySuggestionErrorKey: @"for further information: http://jsonapi.org"
                               };
    
    NSError *mimeTypeError = [NSError errorWithDomain:JSONAPIClientErrorDomain code:kMimetypeError userInfo:userInfo];
    
    return mimeTypeError;

    
}

- (void) returnCallbackWithError: (NSError *) error{

    if(_completionHandler)
        _completionHandler(nil, _requestReceivedStatusCode, error);

}

@end
