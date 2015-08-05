//
//  JSONAPITopLevel.m
//  JSONAPI
//
//  Created by Josh Holtz on 12/23/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#import "JSONAPIDocument.h"
#import "JSONAPIResource.h"
#import "JSONAPIError.h"

@interface JSONAPIDocument(){

    NSDictionary *_dictionary;
}

@end

@implementation JSONAPIDocument

#pragma mark - Class

+ (instancetype)jsonAPIWithDictionary:(NSDictionary *)dictionary {
    return [[JSONAPIDocument alloc] initWithDictionary:dictionary];
}

+ (instancetype)jsonAPIWithString:(NSString *)string {
    return [[JSONAPIDocument alloc] initWithString:string];
}

#pragma mark - Instance

- (instancetype)initWithDictionary:(NSDictionary*)dictionary {
    self = [super init];
    if (self) {
        [self inflateWithDictionary:dictionary];
    }
    return self;
}

- (instancetype)initWithString:(NSString*)string {
    self = [super init];
    if (self) {
        [self inflateWithString:string];
    }
    return self;
}

- (void)inflateWithString:(NSString*)string {
    id json = [NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    
    if ([json isKindOfClass:[NSDictionary class]] == YES) {
        [self inflateWithDictionary:json];
    }
}

#pragma mark - Resources

- (BOOL)hasErrors {
    return _errors.count > 0;
}

#pragma mark - Private

- (void)inflateWithDictionary:(NSDictionary*)dictionary {
    
    _dictionary = dictionary;
    
    _meta = dictionary[@"meta"];
    _jsonApi = dictionary[@"jsonApi"];
    _links = dictionary[@"links"];
    
    id rawData = _dictionary[@"data"];
    _data = [self inflateResourceData: rawData];
    
    NSArray *rawIncludedArray = _dictionary[@"included"];
    _included = [self inflateResourceData: rawIncludedArray];
    
    NSMutableArray *returnedErrors = [NSMutableArray new];
    for (NSDictionary *rawError in _dictionary[@"errors"]) {
        
        JSONAPIError *resource = [[JSONAPIError alloc] initWithDictionary:rawError];
        if (resource) [returnedErrors addObject:resource];
    }
    _errors = returnedErrors;
}

- (id)inflateResourceData:(id) data {
    
    if([data isKindOfClass:[NSDictionary class]])
        return [JSONAPIResource jsonAPIResource: data];
    else if([data isKindOfClass:[NSArray class]])
        return [JSONAPIResource jsonAPIResources: data];
    else
        return nil;
}

- (NSString *) toJson{
    
    
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:_dictionary
                                                       options:0
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"JSONAPIDocument error, unable to parse document to json: %@", error.localizedDescription);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    return jsonString;

}

@end
