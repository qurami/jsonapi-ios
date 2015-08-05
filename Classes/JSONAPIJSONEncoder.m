//
//  JSONAPIJSONEncoder.m
//  JSONAPI
//
//  Created by Marco Musella on 05/08/15.
//  Copyright (c) 2015 Josh Holtz. All rights reserved.
//

#import "JSONAPIJSONEncoder.h"
#import "JSONAPIDocument.h"
#import "JSONAPIResource.h"
#import "JSONAPIError.h"


@implementation JSONAPIJSONEncoder


+ (NSString *) jsonEncodedStringForJSONAPIDocument: (JSONAPIDocument *) document{
    
    NSMutableDictionary *rawDocument = [NSMutableDictionary new];
    
    [rawDocument setObject: [self jsonEncodableValueForObject: document.meta] forKey:@"meta"];
    [rawDocument setObject: [self jsonEncodableValueForObject: document.links] forKey:@"links"];
    [rawDocument setObject: [self jsonEncodableValueForObject: document.jsonApi] forKey:@"jsonApi"];
    
    id rawData = nil;
    if(document.data){
        
        if([document.data isKindOfClass: [JSONAPIResource class]])
            rawData = [self jsonEncodedStringForJSONAPIResource: document.data];
        else if([document.data isKindOfClass:[NSArray class]] && [document.data count] > 0){
            
            NSMutableArray *rawData = [[NSMutableArray alloc] initWithCapacity: [document.data count]];
            
            for (JSONAPIResource *thisResource in document.data) {
                NSString *jsonResource = [self jsonEncodedStringForJSONAPIResource: thisResource];
                if(jsonResource)
                    [rawData addObject: jsonResource];
            }
        }
    }
    
    [rawDocument setObject:[self jsonEncodableValueForObject: rawData] forKey:@"data"];
    
    
    
    NSMutableArray *rawIncluded = nil;
    if(document.included && [document.included count] > 0){
        rawIncluded = [[NSMutableArray alloc] initWithCapacity: [document.included count]];
        
        for (JSONAPIResource *thisIncludedResource in document.included) {
            NSString *jsonIncludedResource = [self jsonEncodedStringForJSONAPIResource: thisIncludedResource];
            if(jsonIncludedResource)
                [rawIncluded addObject: jsonIncludedResource];
        }
    }
    
    [rawDocument setObject: [self jsonEncodableValueForObject: rawIncluded] forKey:@"included"];
    
    NSMutableArray *rawErrors = nil;
    if(document.errors && [document.errors count] > 0){
        
        rawErrors = [[NSMutableArray alloc] initWithCapacity: [document.errors count]];
        for (JSONAPIError *thisError in document.errors) {
            NSString *jsonErrorString = [self jsonEncodedStringForJSONAPIError: thisError];
            if(thisError)
                [rawErrors addObject: jsonErrorString];
        }
    }
    
    [rawDocument setObject: [self jsonEncodableValueForObject: rawErrors] forKey:@"errors"];
    
    return [self jsonParseDictionary: rawDocument];
}

+ (NSString *) jsonEncodedStringForJSONAPIResource: (JSONAPIResource *) resource{
    
    NSDictionary *rawResource = @{
                                  @"id" : [self jsonEncodableValueForObject: resource.ID],
                                  @"type" : [self jsonEncodableValueForObject:resource.type],
                                  @"attributes" : [self jsonEncodableValueForObject:resource.attributes],
                                  @"relationships" : [self jsonEncodableValueForObject:resource.relationships]
                                  };
    
    return [self jsonParseDictionary: rawResource];
    
    
    
}

+ (NSString *) jsonEncodedStringForJSONAPIError: (JSONAPIError *) jsonapiError{
    
    NSDictionary *rawError = @{
                               @"id" : [self jsonEncodableValueForObject: jsonapiError.ID],
                               @"status" : [self jsonEncodableValueForObject: jsonapiError.status],
                               @"code" : [self jsonEncodableValueForObject: jsonapiError.code],
                               @"title" : [self jsonEncodableValueForObject: jsonapiError.title],
                               @"detail" : [self jsonEncodableValueForObject: jsonapiError.detail],
                               @"links" : [self jsonEncodableValueForObject: jsonapiError.links],
                               @"source" : [self jsonEncodableValueForObject: jsonapiError.source],
                               @"meta" : [self jsonEncodableValueForObject: jsonapiError.meta]
                               };
    
    return [self jsonParseDictionary: rawError];
}


+ (NSString *) jsonParseDictionary: (NSDictionary *) dictionary{
    
    NSString *jsonString = nil;
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:0
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"JSONAPIJSONEncoder error, unable to parse dictionary: %@ to json: %@", dictionary, error.localizedDescription);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    
    
    return jsonString;
    
    
    
}

+ (id) jsonEncodableValueForObject: (id) object{
    
    if(object)
        return object;
    else
        return [NSNull null];
}

@end
