//
//  JSONAPIClient+JSONPatchExtension.m
//  JSONAPI
//
//  Created by Marco Musella on 17/11/15.
//  Copyright © 2015 Josh Holtz. All rights reserved.
//

#import "JSONAPIClient+JSONPatchExtension.h"
#import "JSONPatchDocument.h"
#import "JSONAPIDocument.h"

@implementation JSONAPIClient (JSONPatchExtension)


- (void) patchWithJsonPatchDocumentArray: (NSArray<JSONPatchDocument *> *) array forResourceAtPath: (NSString *) resourcePath completionHandler: (void(^)(NSArray<JSONAPIDocument *> *documents,NSInteger statusCode, NSError *error)) completionHandler{
    
    NSMutableArray *rawData = [[NSMutableArray alloc] initWithCapacity: [array count]];
    
    for(JSONPatchDocument *thisDoc in array){
        [rawData addObject:[thisDoc toDictionary]];
    }
    
    
    NSError *serializationError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:rawData
                                                       options:0
                                                         error:&serializationError];
    
    if (serializationError) {
        if(completionHandler)
            completionHandler(nil,-101, [self jsonPatchSerializationError]);

    } else {

        NSString *jsonString = [[NSString alloc] initWithData: jsonData encoding: NSUTF8StringEncoding];
        
        [self setContentTypeExtension:@[@"jsonpatch"] acceptExtensions:@[@"jsonpatch"]];
        [self appendRequestBody: jsonString];
        [self genericRequestWithHTTPMethod:@"PATCH" resourcePath: resourcePath completionHandler:^(NSData *retrievedData, NSInteger statusCode, NSError *error) {
            if(completionHandler){
                
                if(error)
                    completionHandler(nil, statusCode, error);
                
                else{
                    
                    NSError *deserializationError;
                    id rawData = [NSJSONSerialization JSONObjectWithData: retrievedData options:0 error: &deserializationError];
                    
                    
                    if(deserializationError){
                        completionHandler(nil, statusCode, [self jsonDocumentsArrayDeserializationError]);
                    }
                    else{
                        
                        NSMutableArray *jsonApiDocumentsArray = [NSMutableArray new];
                        
                        if([rawData isKindOfClass:[NSArray class]]){
                            NSMutableArray *jsonApiDocumentsArray = [[NSMutableArray alloc] initWithCapacity:[rawData count]];
                            for(NSDictionary *rawJsonDocumentDictionary in rawData){
                                JSONAPIDocument *thisDoc = [[JSONAPIDocument alloc] initWithDictionary: rawJsonDocumentDictionary];
                                if(thisDoc)
                                    [jsonApiDocumentsArray addObject: thisDoc];
                            }
                            
                        }
                        else if ([rawData isKindOfClass: [NSDictionary class]]){
                            
                            JSONAPIDocument *thisDoc = [[JSONAPIDocument alloc] initWithDictionary: rawData];
                            if(thisDoc)
                                [jsonApiDocumentsArray addObject: thisDoc];
                            
                        }
                        
                        if([jsonApiDocumentsArray count] > 0)
                            completionHandler(jsonApiDocumentsArray, statusCode, nil);
                        else
                            completionHandler(nil,statusCode,[self jsonDocumentsArrayDeserializationError]);
                        
                    }
                    
                }
            }

        }];
    }

}

- (NSError *) jsonPatchSerializationError{
    
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: @"data is not serializable to JSON format",
                               NSLocalizedFailureReasonErrorKey: @"unable to serialize your json patch array, check if value is serializable to json",
                               NSLocalizedRecoverySuggestionErrorKey: @"for further information: https://github.com/qurami"
                               };
    
    NSError *malformedDataError = [NSError errorWithDomain:JSONAPIClientErrorDomain code:-101 userInfo:userInfo];
    
    return malformedDataError;
    
}

- (NSError *) jsonDocumentsArrayDeserializationError{
    
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: @"unable to deserialize response to jsonDocuments array",
                               NSLocalizedFailureReasonErrorKey: @"unable to deserialize NSData in an NSArray of JSONAPIDocument because data might be malformed",
                               NSLocalizedRecoverySuggestionErrorKey: @"for further information: http://jsonapi.org/extensions/jsonpatch/"
                               };
    
    NSError *malformedDataError = [NSError errorWithDomain:JSONAPIClientErrorDomain code:kMalformedContentError userInfo:userInfo];
    
    return malformedDataError;
    
}


@end
