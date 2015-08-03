//
//  JSONAPICall.h
//  JSONAPI
//
//  Created by Marco Musella on 30/07/15.
//  Copyright (c) 2015 Josh Holtz. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JSONAPIDocument;

@interface JSONAPICall : NSObject <NSURLSessionDataDelegate, NSURLSessionTaskDelegate>

//the endpoint of the json api call
@property (strong, nonatomic) NSString *endpoint;


//for customization of default session configuration and for basic http auth
@property (strong, nonatomic) NSURLSessionConfiguration *sessionConfiguration;
@property (strong, nonatomic) NSURLCredential *sessionCredential;


- (void) appendAdditionalHTTPHeaders: (NSDictionary *) additionalHeaders;


- (void) getJSONAPIDocumentWithPath: (NSString *) path completionHandler: (void(^)(JSONAPIDocument *jsonApi, NSInteger statusCode)) completionHandler failureHandler: (void(^)(NSError *error)) failureHandler;

- (void) getJSONAPIDocumentWithPath: (NSString *) path includedResourceTypes: (NSArray *) includedResourceTypes completionHandler: (void(^)(JSONAPIDocument *jsonApi, NSInteger statusCode)) completionHandler failureHandler: (void(^)(NSError *error)) failureHandler;

@end
