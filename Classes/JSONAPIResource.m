//
//  JSONAPIResource.m
//  JSONAPI
//
//  Created by Josh Holtz on 12/24/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#import "JSONAPIResource.h"

#import "JSONAPIResourceFormatter.h"
#import "JSONAPIResourceModeler.h"

#import <objc/runtime.h>
#import <objc/message.h>

#pragma mark - JSONAPIResource

@interface JSONAPIResource(){
    
    NSDictionary *_dictionary;
}


@end

@implementation JSONAPIResource

#pragma mark -
#pragma mark - Class Methods

+ (NSArray*)jsonAPIResources:(NSArray*)array {
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity: [array count]];
    for (NSDictionary *dict in array) {
        NSString *type = dict[@"type"] ?: @"";
        Class resourceObjectClass = [JSONAPIResourceModeler resourceForLinkedType:type];
        [mutableArray addObject:[[resourceObjectClass alloc] initWithDictionary:dict]];
    }
    
    return mutableArray;
}

+ (id)jsonAPIResource:(NSDictionary*)dictionary {
    NSString *type = dictionary[@"type"] ?: @"";
    Class resourceObjectClass = [JSONAPIResourceModeler resourceForLinkedType:type];
    
    return [[resourceObjectClass alloc] initWithDictionary:dictionary];
}

#pragma mark -
#pragma mark - Instance Methods


- (id)initWithDictionary:(NSDictionary*)dict {
    self = [super init];
    if (self) {
        [self setWithDictionary:dict];
    }
    return self;
}

- (id)objectForKey:(NSString*)key {
    return [_dictionary objectForKey:key];
}

- (NSDictionary *)mapMembersToProperties {
    return [[NSDictionary alloc] init];
}

- (NSDictionary *) mapRelationshipsToProperties{

    return [[NSDictionary alloc] init];
}

- (BOOL)setWithResource:(id)otherResource {
    if ([otherResource isKindOfClass:[self class]] == YES) {
        
        return YES;
    }
    
    return NO;
}

- (void)setWithDictionary: (NSDictionary*) rawResourceObjectDictionary {
    
    _dictionary = rawResourceObjectDictionary;
    

    if(!rawResourceObjectDictionary[@"id"] || rawResourceObjectDictionary[@"id"] == [NSNull null] || [rawResourceObjectDictionary[@"id"] length] == 0){
        NSLog(@"%@ warning: object is missing id, every jsonapiresource MUST have an id. For further reading please refer to: http://jsonapi.org/format/#document-resource-objects ", NSStringFromClass([self class]));
    }
    else
        self.ID = rawResourceObjectDictionary[@"id"];
    
    if(!rawResourceObjectDictionary[@"type"] ||  rawResourceObjectDictionary[@"type"] == [NSNull null] || [rawResourceObjectDictionary[@"type"] length] == 0){
        NSLog(@"%@ warning: object is missing type, every jsonapiresource MUST have a type. For further reading please refer to: http://jsonapi.org/format/#document-resource-objects ", NSStringFromClass([self class]));
    }
    else
        self.type = rawResourceObjectDictionary[@"type"];
    
    
    
    NSDictionary *rawResourceObjectAttributesDictionary = (rawResourceObjectDictionary[@"attributes"] && (rawResourceObjectDictionary[@"attributes"] != [NSNull null])) ? rawResourceObjectDictionary[@"attributes"] : nil;
    
    if(rawResourceObjectAttributesDictionary){
        self.attributes = rawResourceObjectAttributesDictionary;
    }
    else
        self.attributes = @{};
    
    
    
    NSDictionary *rawResourceObjectRelationshipsDictionary = (rawResourceObjectDictionary[@"relationships"] && (rawResourceObjectDictionary[@"relationships"] != [NSNull null])) ? rawResourceObjectDictionary[@"relationships"] : nil;
    if(rawResourceObjectRelationshipsDictionary){
        self.relationships = rawResourceObjectRelationshipsDictionary;
    }
    else
        rawResourceObjectRelationshipsDictionary = @{};
    
    NSDictionary *userMap = [self mapMembersToProperties];
    
    if([userMap count]>0){
        
        for (NSString *key in [userMap allKeys]) {
            
                if ([rawResourceObjectAttributesDictionary objectForKey:key] != nil && [rawResourceObjectAttributesDictionary objectForKey:key] != [NSNull null]) {
                    
                    NSString *propertyName = [userMap objectForKey:key];
                    
                    NSRange formatRange = [propertyName rangeOfString:@":"];
                    
                    @try {
                        if (formatRange.location != NSNotFound) {
                            NSString *formatFunction = [propertyName substringToIndex:formatRange.location];
                            propertyName = [propertyName substringFromIndex:(formatRange.location+1)];
                            
                            [self setValue:[JSONAPIResourceFormatter performFormatBlock:[rawResourceObjectAttributesDictionary objectForKey:key] withName:formatFunction] forKey:propertyName ];
                        } else {
                            [self setValue:[rawResourceObjectAttributesDictionary objectForKey:key] forKey:propertyName ];
                        }
                    }
                    @catch (NSException *exception) {
                        NSLog(@"%@ warning: %@", NSStringFromClass([self class]),[exception description]);
                    }
                }
            }
        }
}


- (NSArray *) getRelatedResourcesFromJSONAPIResourcesArray: (NSArray *) array{
    
    NSMutableArray *relationships = [NSMutableArray new];

    
    for(NSDictionary *relationship in [self.relationships allValues]){
        
        NSDictionary *relationshipData = (relationship[@"data"] && (relationship[@"data"] != [NSNull null])) ? relationship[@"data"] : nil;
        
        if(relationshipData){
            
            if([relationshipData isKindOfClass:[NSArray class]]){
                for (NSDictionary *thisResourceIdentifier in relationshipData) {
                    NSString *relationshipType = thisResourceIdentifier[@"type"];
                    NSString *relationshipId = thisResourceIdentifier[@"id"];
                    
                    for(JSONAPIResource *thisResource in array){
                        if([thisResource.ID isEqualToString: relationshipId] && [thisResource.type isEqualToString: relationshipType])
                            [relationships addObject: thisResource];
                    }
                    
                }
            }
            else{
                NSString *relationshipType = relationshipData[@"type"];
                NSString *relationshipId = relationshipData[@"id"];
                
                for(JSONAPIResource *thisResource in array){
                    if([thisResource.ID isEqualToString: relationshipId] && [thisResource.type isEqualToString: relationshipType])
                        [relationships addObject: thisResource];
                }
            }
        }
    }
    
    return relationships;

}


@end
