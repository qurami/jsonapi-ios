//
//  JSONAPICall.h
//  JSONAPI
//
//  Created by Marco Musella on 30/07/15.
//  Copyright (c) 2015 Josh Holtz. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JSONAPI;

@interface JSONAPICall : NSObject <NSURLSessionDataDelegate, NSURLSessionTaskDelegate>

//the endpoint of the json api call
@property (strong, nonatomic) NSString *endpoint;

//array of resources to include to the received jsonapi document
@property (strong, nonatomic) NSArray *includedResources;


//for customization of default session configuration and for basic http auth
@property (strong, nonatomic) NSURLSessionConfiguration *sessionConfiguration;
@property (strong, nonatomic) NSURLCredential *sessionCredential;


- (void) appendAdditionalHTTPHeaders: (NSDictionary *) additionalHeaders;


- (void) getJSONAPIWithPath: (NSString *) path completionHandler: (void(^)(JSONAPI *jsonApi, NSInteger statusCode)) completionHandler failureHandler: (void(^)(NSError *error)) failureHandler;

- (void) getJSONAPIWithPath: (NSString *) path includedResourceTypes: (NSArray *) includedResourceTypes completionHandler: (void(^)(JSONAPI *jsonApi, NSInteger statusCode)) completionHandler failureHandler: (void(^)(NSError *error)) failureHandler;

@end
