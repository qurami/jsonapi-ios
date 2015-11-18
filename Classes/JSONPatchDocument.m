//
//  JSONPatchDocument.m
//  JSONAPI
//
//  Created by Marco Musella on 17/11/15.
//  Copyright © 2015 Josh Holtz. All rights reserved.
//

#import "JSONPatchDocument.h"

@implementation JSONPatchDocument


- (NSString *) convertToJsonStringWithError: (NSError **) error{
    
    NSError *jsonDataError;
    NSData *jsonData = [self convertToJsonDataWithError: &jsonDataError];
    
    if(jsonDataError){
        
        if(error)
            *error = jsonDataError;
        
        return nil;
        
    }
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

}

- (NSData *) convertToJsonDataWithError: (NSError **) error{
    
    if(![NSJSONSerialization isValidJSONObject: self.value]){
        
        if(error){
            *error = [self valueNotSerializableError];
        }
        
        return nil;
    }
    
    
    NSError *serializationError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:0
                                                         error:&serializationError];
    
    if(serializationError){
    
        if(error)
            *error = serializationError;
        
        return nil;
    }
    
    return jsonData;
}

- (NSError *) valueNotSerializableError{
    return [NSError errorWithDomain:@"JSONPatchDocumentErrorDomain" code:-101 userInfo:@{NSLocalizedDescriptionKey : @"value provided is not json encodable"}];
}


- (NSDictionary *) toDictionary{

    NSString *operation = nil;
    switch (self.op) {
        case JSONPatchOperationAdd:
            operation = @"add";
            break;
        case JSONPatchOperationRemove:
            operation = @"remove";
            break;
        case JSONPatchOperationReplace:
            operation = @"replace";
            break;
        case JSONPatchOperationCopy:
            operation = @"copy";
            break;
        case JSONPatchOperationMove:
            operation = @"move";
            break;
        case JSONPatchOperationTest:
            operation = @"test";
            break;
        default:
            break;
    }
    
    return @{@"op" : operation, @"path" : self.path, @"value" : self.value};

}

@end
