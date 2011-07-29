//
//  CSAPI+Lists.m
//  CreateSend
//
//  Created by Nathan de Vries on 29/07/11.
//  Copyright 2011 Nathan de Vries. All rights reserved.
//

#import "CSAPI+Lists.h"

@implementation CSAPI (Lists)

- (void)createListWithClientID:(NSString *)clientID
                         title:(NSString *)title
               unsubscribePage:(NSString *)unsubscribePage
       confirmationSuccessPage:(NSString *)confirmationSuccessPage
            shouldConfirmOptIn:(BOOL)shouldConfirmOptIn
             completionHandler:(void (^)(NSString* listID))completionHandler
                  errorHandler:(CSAPIErrorHandler)errorHandler {
  
  __block CSAPIRequest* request = [CSAPIRequest requestWithAPIKey:self.APIKey
                                                             slug:[NSString stringWithFormat:@"lists/%@", clientID]];
  
  request.requestObject = [NSDictionary dictionaryWithObjectsAndKeys:
                           title, @"Title",
                           unsubscribePage, @"UnsubscribePage",
                           confirmationSuccessPage, @"ConfirmationSuccessPage",
                           [NSNumber numberWithBool:shouldConfirmOptIn], @"ConfirmedOptIn",
                           nil];
  
  [request setCompletionBlock:^{
    completionHandler(request.parsedResponse);
  }];
  
  [request setFailedBlock:^{ errorHandler(request.error); }];
  [request startAsynchronous];
}

- (void)updateListWithListID:(NSString *)listID
                       title:(NSString *)title
             unsubscribePage:(NSString *)unsubscribePage
     confirmationSuccessPage:(NSString *)confirmationSuccessPage
          shouldConfirmOptIn:(BOOL)shouldConfirmOptIn
           completionHandler:(void (^)(void))completionHandler
                errorHandler:(CSAPIErrorHandler)errorHandler {
  
  __block CSAPIRequest* request = [CSAPIRequest requestWithAPIKey:self.APIKey
                                                             slug:[NSString stringWithFormat:@"lists/%@", listID]];
  request.requestMethod = @"PUT";
  request.requestObject = [NSDictionary dictionaryWithObjectsAndKeys:
                           title, @"Title",
                           unsubscribePage, @"UnsubscribePage",
                           confirmationSuccessPage, @"ConfirmationSuccessPage",
                           [NSNumber numberWithBool:shouldConfirmOptIn], @"ConfirmedOptIn", nil];
  
  [request setCompletionBlock:completionHandler];
  [request setFailedBlock:^{ errorHandler(request.error); }];
  [request startAsynchronous];
}

- (void)getListsWithClientID:(NSString *)clientID
           completionHandler:(void (^)(NSArray* lists))completionHandler
                errorHandler:(CSAPIErrorHandler)errorHandler {
  
  __block CSAPIRequest* request = [CSAPIRequest requestWithAPIKey:self.APIKey
                                                             slug:[NSString stringWithFormat:@"clients/%@/lists",
                                                                   clientID]];
  
  [request setCompletionBlock:^{
    NSMutableArray* lists = [NSMutableArray array];
    for (NSDictionary* listDict in request.parsedResponse) {
      [lists addObject:[CSList listWithDictionary:listDict]];
    }
    completionHandler([NSArray arrayWithArray:lists]);
  }];
  
  [request setFailedBlock:^{ errorHandler(request.error); }];
  [request startAsynchronous];
}

- (void)deleteListWithID:(NSString *)listID
       completionHandler:(void (^)(void))completionHandler
            errorHandler:(CSAPIErrorHandler)errorHandler {
  
  __block CSAPIRequest* request = [CSAPIRequest requestWithAPIKey:self.APIKey
                                                             slug:[NSString stringWithFormat:@"lists/%@", listID]];
  request.requestMethod = @"DELETE";
  
  [request setCompletionBlock:completionHandler];
  [request setFailedBlock:^{ errorHandler(request.error); }];
  [request startAsynchronous];
}

- (void)getListDetailsWithListID:(NSString *)listID
               completionHandler:(void (^)(CSList* list))completionHandler
                    errorHandler:(CSAPIErrorHandler)errorHandler {
  
  __block CSAPIRequest* request = [CSAPIRequest requestWithAPIKey:self.APIKey
                                                             slug:[NSString stringWithFormat:@"lists/%@", listID]];
  
  [request setCompletionBlock:^{
    CSList* list = [CSList listWithDictionary:request.parsedResponse];
    completionHandler(list);
  }];
  
  [request setFailedBlock:^{ errorHandler(request.error); }];
  [request startAsynchronous];
}

- (void)getListStatisticsWithListID:(NSString *)listID
                  completionHandler:(void (^)(NSDictionary* listStatisticsData))completionHandler
                       errorHandler:(CSAPIErrorHandler)errorHandler {
  
  __block CSAPIRequest* request = [CSAPIRequest requestWithAPIKey:self.APIKey
                                                             slug:[NSString stringWithFormat:@"lists/%@/stats", listID]];
  
  [request setCompletionBlock:^{
    completionHandler(request.parsedResponse);
  }];
  
  [request setFailedBlock:^{ errorHandler(request.error); }];
  [request startAsynchronous];
}

- (void)getSubscribersWithListID:(NSString *)listID
                            slug:(NSString *)slug
                            date:(NSDate *)date
                            page:(NSUInteger)page
                        pageSize:(NSUInteger)pageSize
                      orderField:(NSString *)orderField
                       ascending:(BOOL)ascending
               completionHandler:(void (^)(CSPaginatedResult* paginatedResult))completionHandler
                    errorHandler:(CSAPIErrorHandler)errorHandler {
  
  NSMutableDictionary* queryParameters;
  queryParameters = [[[CSAPIRequest paginationParametersWithPage:page
                                                        pageSize:pageSize
                                                      orderField:orderField
                                                       ascending:ascending] mutableCopy] autorelease];
  
  NSString* dateString = [[CSAPIRequest sharedDateFormatter] stringFromDate:date];
  [queryParameters setObject:dateString forKey:@"Date"];
  
  __block CSAPIRequest* request = [CSAPIRequest requestWithAPIKey:self.APIKey
                                                             slug:[NSString stringWithFormat:@"lists/%@/%@", listID, slug]
                                                  queryParameters:queryParameters];
  
  [request setCompletionBlock:^{
    CSPaginatedResult* result = [CSPaginatedResult resultWithDictionary:request.parsedResponse];
    completionHandler(result);
  }];
  
  [request setFailedBlock:^{ errorHandler(request.error); }];
  [request startAsynchronous];
}

- (void)getActiveSubscribersWithListID:(NSString *)listID
                                  date:(NSDate *)date
                                  page:(NSUInteger)page
                              pageSize:(NSUInteger)pageSize
                            orderField:(NSString *)orderField
                             ascending:(BOOL)ascending
                     completionHandler:(void (^)(CSPaginatedResult* paginatedResult))completionHandler
                          errorHandler:(CSAPIErrorHandler)errorHandler {
  
  [self getSubscribersWithListID:listID
                            slug:@"active"
                            date:nil
                            page:page
                        pageSize:pageSize
                      orderField:orderField
                       ascending:ascending
               completionHandler:completionHandler
                    errorHandler:errorHandler];
}

- (void)getUnsubscribedSubscribersWithListID:(NSString *)listID
                                        date:(NSDate *)date
                                        page:(NSUInteger)page
                                    pageSize:(NSUInteger)pageSize
                                  orderField:(NSString *)orderField
                                   ascending:(BOOL)ascending
                           completionHandler:(void (^)(CSPaginatedResult* paginatedResult))completionHandler
                                errorHandler:(CSAPIErrorHandler)errorHandler {
  
  [self getSubscribersWithListID:listID
                            slug:@"unsubscribed"
                            date:nil
                            page:page
                        pageSize:pageSize
                      orderField:orderField
                       ascending:ascending
               completionHandler:completionHandler
                    errorHandler:errorHandler];
}

- (void)getBouncedSubscribersWithListID:(NSString *)listID
                                   date:(NSDate *)date
                                   page:(NSUInteger)page
                               pageSize:(NSUInteger)pageSize
                             orderField:(NSString *)orderField
                              ascending:(BOOL)ascending
                      completionHandler:(void (^)(CSPaginatedResult* paginatedResult))completionHandler
                           errorHandler:(CSAPIErrorHandler)errorHandler {
  
  [self getSubscribersWithListID:listID
                            slug:@"bounced"
                            date:nil
                            page:page
                        pageSize:pageSize
                      orderField:orderField
                       ascending:ascending
               completionHandler:completionHandler
                    errorHandler:errorHandler];
}

- (void)getListSegmentsWithListID:(NSString *)listID
                completionHandler:(void (^)(NSArray* listSegments))completionHandler
                     errorHandler:(CSAPIErrorHandler)errorHandler {
  
  __block CSAPIRequest* request = [CSAPIRequest requestWithAPIKey:self.APIKey
                                                             slug:[NSString stringWithFormat:@"lists/%@/segments", listID]];
  
  [request setCompletionBlock:^{
    completionHandler(request.parsedResponse);
  }];
  
  [request setFailedBlock:^{ errorHandler(request.error); }];
  [request startAsynchronous];
}

# pragma mark - Custom Fields

- (void)getCustomFieldsWithListID:(NSString *)listID
                completionHandler:(void (^)(NSArray* customFields))completionHandler
                     errorHandler:(CSAPIErrorHandler)errorHandler {
  
  __block CSAPIRequest* request = [CSAPIRequest requestWithAPIKey:self.APIKey
                                                             slug:[NSString stringWithFormat:@"lists/%@/customfields", listID]];
  
  [request setCompletionBlock:^{
    NSMutableArray* customFields = [NSMutableArray array];
    for (NSDictionary* customFieldDict in request.parsedResponse) {
      [customFields addObject:[CSCustomField customFieldWithDictionary:customFieldDict]];
    }
    completionHandler([NSArray arrayWithArray:customFields]);
  }];
  
  [request setFailedBlock:^{ errorHandler(request.error); }];
  [request startAsynchronous];
}

- (void)createCustomFieldWithListID:(NSString *)listID
                        customField:(CSCustomField *)customField
                  completionHandler:(void (^)(NSString* customFieldKey))completionHandler
                       errorHandler:(CSAPIErrorHandler)errorHandler {
  
  __block CSAPIRequest* request = [CSAPIRequest requestWithAPIKey:self.APIKey
                                                             slug:[NSString stringWithFormat:@"lists/%@/customfields", listID]];
  
  NSMutableDictionary* requestObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        customField.name, @"FieldName",
                                        [customField dataTypeString], @"DataType", nil];
  
  if (customField.options) {
    [requestObject setObject:customField.options
                      forKey:@"Options"];
  }
  
  request.requestObject = requestObject;
  
  [request setCompletionBlock:^{
    completionHandler(request.parsedResponse);
  }];
  
  [request setFailedBlock:^{ errorHandler(request.error); }];
  [request startAsynchronous];
}

- (void)updateCustomFieldWithListID:(NSString *)listID
                     customFieldKey:(NSString *)fieldKey
                            options:(NSArray *)options
                       keepExisting:(BOOL)keepExisting
                  completionHandler:(void (^)(void))completionHandler
                       errorHandler:(CSAPIErrorHandler)errorHandler {
  
  NSString* slug = [NSString stringWithFormat:@"lists/%@/customfields/%@/options", listID, fieldKey];
  __block CSAPIRequest* request = [CSAPIRequest requestWithAPIKey:self.APIKey
                                                             slug:slug];
  request.requestMethod = @"PUT";
  request.requestObject = [NSDictionary dictionaryWithObjectsAndKeys:
                           options, @"Options",
                           [NSNumber numberWithBool:keepExisting], @"KeepExistingOptions", nil];
  
  [request setCompletionBlock:completionHandler];
  [request setFailedBlock:^{ errorHandler(request.error); }];
  [request startAsynchronous];
}

- (void)deleteCustomFieldWithListID:(NSString *)listID
                     customFieldKey:(NSString *)fieldKey
                  completionHandler:(void (^)(void))completionHandler
                       errorHandler:(CSAPIErrorHandler)errorHandler {
  
  NSString* slug = [NSString stringWithFormat:@"lists/%@/customfields/%@", listID, fieldKey];
  __block CSAPIRequest* request = [CSAPIRequest requestWithAPIKey:self.APIKey
                                                             slug:slug];
  request.requestMethod = @"DELETE";
  
  [request setCompletionBlock:completionHandler];
  [request setFailedBlock:^{ errorHandler(request.error); }];
  [request startAsynchronous];
}

# pragma mark - Webhooks

- (void)createWebhookWithListID:(NSString *)listID
                         events:(NSArray *)events
                      URLString:(NSString *)URLString
                  payloadFormat:(NSString *)payloadFormat
              completionHandler:(void (^)(NSString* webhookID))completionHandler
                   errorHandler:(CSAPIErrorHandler)errorHandler {
  
  __block CSAPIRequest* request = [CSAPIRequest requestWithAPIKey:self.APIKey
                                                             slug:[NSString stringWithFormat:@"lists/%@/webhooks", listID]];
  
  request.requestObject = [NSDictionary dictionaryWithObjectsAndKeys:
                           events, @"Events",
                           URLString, @"Url",
                           payloadFormat, @"PayloadFormat", nil];
  
  [request setCompletionBlock:^{
    completionHandler(request.parsedResponse);
  }];
  
  [request setFailedBlock:^{ errorHandler(request.error); }];
  [request startAsynchronous];
}

- (void)getWebhooksWithListID:(NSString *)listID
            completionHandler:(void (^)(NSArray* webhooks))completionHandler
                 errorHandler:(CSAPIErrorHandler)errorHandler {
  
  __block CSAPIRequest* request = [CSAPIRequest requestWithAPIKey:self.APIKey
                                                             slug:[NSString stringWithFormat:@"lists/%@/webhooks", listID]];
  
  [request setCompletionBlock:^{
    completionHandler(request.parsedResponse);
  }];
  
  [request setFailedBlock:^{ errorHandler(request.error); }];
  [request startAsynchronous];
}

- (void)testWebhookWithListID:(NSString *)listID
                    webhookID:(NSString *)webhookID
            completionHandler:(void (^)(void))completionHandler
                 errorHandler:(CSAPIErrorHandler)errorHandler {
  
  NSString* slug = [NSString stringWithFormat:@"lists/%@/webhooks/%@/test", listID, webhookID];
  __block CSAPIRequest* request = [CSAPIRequest requestWithAPIKey:self.APIKey
                                                             slug:slug];
  
  [request setCompletionBlock:completionHandler];
  [request setFailedBlock:^{ errorHandler(request.error); }];
  [request startAsynchronous];
}

- (void)deleteWebhookWithListID:(NSString *)listID
                      webhookID:(NSString *)webhookID
              completionHandler:(void (^)(void))completionHandler
                   errorHandler:(CSAPIErrorHandler)errorHandler {
  
  NSString* slug = [NSString stringWithFormat:@"lists/%@/webhooks/%@", listID, webhookID];
  __block CSAPIRequest* request = [CSAPIRequest requestWithAPIKey:self.APIKey
                                                             slug:slug];
  request.requestMethod = @"DELETE";
  
  [request setCompletionBlock:completionHandler];
  [request setFailedBlock:^{ errorHandler(request.error); }];
  [request startAsynchronous];  
}

- (void)activateWebhookWithListID:(NSString *)listID
                        webhookID:(NSString *)webhookID
                completionHandler:(void (^)(void))completionHandler
                     errorHandler:(CSAPIErrorHandler)errorHandler {
  
  NSString* slug = [NSString stringWithFormat:@"lists/%@/webhooks/%@/activate", listID, webhookID];
  __block CSAPIRequest* request = [CSAPIRequest requestWithAPIKey:self.APIKey
                                                             slug:slug];
  request.requestMethod = @"PUT";
  
  [request setCompletionBlock:completionHandler];
  [request setFailedBlock:^{ errorHandler(request.error); }];
  [request startAsynchronous];  
}

- (void)deactivateWebhookWithListID:(NSString *)listID
                          webhookID:(NSString *)webhookID
                  completionHandler:(void (^)(void))completionHandler
                       errorHandler:(CSAPIErrorHandler)errorHandler {
  
  NSString* slug = [NSString stringWithFormat:@"lists/%@/webhooks/%@/deactivate", listID, webhookID];
  __block CSAPIRequest* request = [CSAPIRequest requestWithAPIKey:self.APIKey
                                                             slug:slug];
  request.requestMethod = @"PUT";
  
  [request setCompletionBlock:completionHandler];
  [request setFailedBlock:^{ errorHandler(request.error); }];
  [request startAsynchronous];  
}

@end
