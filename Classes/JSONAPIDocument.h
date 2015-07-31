//
//  JSONAPI.h
//  JSONAPI
//
//  Created by Josh Holtz on 12/23/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JSONAPIResource;

@interface JSONAPIDocument : NSObject


//mandatory members
@property (nonatomic, strong, readonly) NSDictionary *meta;
@property (nonatomic, strong, readonly) id data;
@property (nonatomic, strong, readonly) NSArray *errors;

//optional members
@property (nonatomic, strong, readonly) NSDictionary *jsonApi;
@property (nonatomic, strong, readonly) NSArray *links;
@property (nonatomic, strong, readonly) NSArray *included;



// Initializers
+ (instancetype)jsonAPIWithDictionary:(NSDictionary *)dictionary;
+ (instancetype)jsonAPIWithString:(NSString *)string;
- (instancetype)initWithDictionary:(NSDictionary*)dictionary;
- (instancetype)initWithString:(NSString*)string;

- (NSArray *) includedResourcesForJSONAPIResource: (JSONAPIResource *) resource;

- (BOOL)hasErrors;

@end
