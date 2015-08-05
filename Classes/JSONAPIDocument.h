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
@property (nonatomic, strong) NSDictionary *meta;
@property (nonatomic, strong) id data;
@property (nonatomic, strong) NSArray *errors;

//optional members
@property (nonatomic, strong) NSDictionary *jsonApi;
@property (nonatomic, strong) NSArray *links;
@property (nonatomic, strong) NSArray *included;



// Initializers
+ (instancetype)jsonAPIDocumentWithDictionary:(NSDictionary *)dictionary;
+ (instancetype)jsonAPIDocumentWithString:(NSString *)string;
- (instancetype)initWithDictionary:(NSDictionary*)dictionary;
- (instancetype)initWithString:(NSString*)string;

- (BOOL)hasErrors;


@end
