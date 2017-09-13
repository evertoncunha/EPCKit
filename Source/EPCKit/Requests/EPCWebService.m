//
//  EPCWebService.m
//
//  Created by Everton Cunha on 08/08/12.
//

#import "EPCWebService.h"
#import "EPCCategories.h"
#import "EPCHTTPRequest.h"

@interface EPCWebService () {
	NSOperationQueue *_operationQueue;
	NSString *_cachePath;
}
@end

@implementation EPCWebService

- (void)dealloc
{
	[self clearDelegateAndCancel];
	[_operationQueue removeObserver:self forKeyPath:@"operationCount"];
}

- (NSOperationQueue*)operationQueue {
	if (!_operationQueue) {
		_operationQueue = [[NSOperationQueue alloc] init];
		[_operationQueue addObserver:self forKeyPath:@"operationCount" options:NSKeyValueObservingOptionNew context:nil];
	}
	return _operationQueue;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (self.handleNetworkActivityIndicator) {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:[_operationQueue operationCount]>0];
	}
}

-(void)clearDelegateAndCancel {
	self.delegate = nil;
	[self cancelAllRequests];
}

-(void)cancelAllRequests {
	@synchronized(self) {
		[_operationQueue removeObserver:self forKeyPath:@"operationCount"];
		[_operationQueue cancelAllOperations];
		_operationQueue = nil;
	}
}

- (BOOL)isRequesting {
	return ([_operationQueue operationCount] > 0);
}

-(void)requestDataWithURL:(NSURL*)url {
	if (url) {
		NSOperationQueue *operationQueue = [self operationQueue];
		
		EPCHTTPRequest *request = [EPCHTTPRequest requestWithURL:url delegate:self];
		request.responseStringEncoding = [self responseStringEncoding];
		[operationQueue addOperation:request];
	}
#ifdef DEBUG
	else {
		NSLog(@"%s Warning: Given URL is nil.", __PRETTY_FUNCTION__);
	}
#endif
}

- (void)requestDataWithRequest:(NSURLRequest *)urlRequest {
	if (urlRequest) {
		NSOperationQueue *operationQueue = [self operationQueue];
		
		EPCHTTPRequest *request = [EPCHTTPRequest requestWithRequest:urlRequest delegate:self];
		request.responseStringEncoding = [self responseStringEncoding];
		[operationQueue addOperation:request];
	}
#ifdef DEBUG
	else {
		NSLog(@"%s Warning: Given NSURLRequest is nil.", __PRETTY_FUNCTION__);
	}
#endif
}

// this is a copy fom requestDataWithURL:, because you may want override this and call super.
-(void)requestData {
	NSString *urlString = [self webServiceURL];
	
	NSURL *url = [NSURL URLWithString:urlString];
	
	if (url) {
		NSOperationQueue *operationQueue = [self operationQueue];
		
		EPCHTTPRequest *request = [EPCHTTPRequest requestWithURL:url delegate:self];
		request.responseStringEncoding = [self responseStringEncoding];
		[operationQueue addOperation:request];
	}
#ifdef DEBUG
	else {
		NSLog(@"%s Warning: Given URL is nil.", __PRETTY_FUNCTION__);
	}
#endif
}

-(void)requestCachedDataFromURLString:(NSString *)urlString {
	NSData *cachedResponse = [self cachedDataFromURLString:urlString];
	if (cachedResponse) {
		[self performSelectorInBackground:@selector(convertToObjectFromRequest:) withObject:cachedResponse];
	}
	else if ([self.delegate respondsToSelector:@selector(epcWebService:noCacheForURLString:)]) {
		[self.delegate epcWebService:self noCacheForURLString:urlString];
	}
}

// this is a copy fom requestCachedDataFromURLString:, because you may want override this and call super.
-(void)requestDataFromCache {
	NSString *urlString = [self webServiceURL];
	NSData *cachedResponse = [self cachedDataFromURLString:urlString];
	if (cachedResponse) {
		[self performSelectorInBackground:@selector(convertToObjectFromRequest:) withObject:cachedResponse];
	}
	else if ([self.delegate respondsToSelector:@selector(epcWebService:noCacheForURLString:)]) {
		[self.delegate epcWebService:self noCacheForURLString:urlString];
	}
}

-(void)simulateReceivedResponseString:(NSString *)responseString {
	if (responseString) {
		[self performSelectorInBackground:@selector(convertToObjectFromRequest:) withObject:responseString];
	}
}

#pragma mark - Response

-(void)epcHTTPRequestStarted:(EPCHTTPRequest *)request {
	if (self.isHandlingNetworkActivityIndicator) {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	}
	if ([self.delegate respondsToSelector:@selector(epcWebService:requestStartedWithURL:)]) {
		NSURL *url = request.url;
		if (!url) {
			url = request.urlRequest.URL;
		}
		[self.delegate epcWebService:self requestStartedWithURL:url];
	}
}

-(void)epcHTTPRequestFailed:(EPCHTTPRequest *)request {
	if ([self.delegate respondsToSelector:@selector(epcWebService:requestFailedWithError:)]) {
		[self.delegate epcWebService:self requestFailedWithError:request.error];
	}
	else {
		NSAssert(_delegate==nil, @"You forgot to implement the delegate for %@", NSStringFromClass([self class]));
	}
}

-(void)epcHTTPRequestFinished:(EPCHTTPRequest *)request {
	if (self.isCachingResponses) {
		[self performSelectorInBackground:@selector(saveRequestToCache:) withObject:request];
	}
	
	[self performSelectorInBackground:@selector(convertToObjectFromRequest:) withObject:request];
}



#pragma mark - Threaded Parser

- (void)convertToObjectFromRequest:(id)requestOrCachedData {
	EPCPagination *pagination = nil;
	NSError *error = nil;
	BOOL *continueAftError = NO;
	BOOL isCache = NO;
	
	EPCHTTPRequest *request = nil;
	
	id responseData = nil;
	
	if ([requestOrCachedData isKindOfClass:[EPCHTTPRequest class]]) {
		request = requestOrCachedData;
		responseData = request.responseData;
	}
	else if ([requestOrCachedData isKindOfClass:[NSData class]]) {
		responseData = requestOrCachedData;
		isCache = YES;
	}
	
	id parsedObj = [self parseToObjectFromData:responseData pagination:&pagination error:&error continueAfterError:&continueAftError];
	
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:5];
	
	if (error) {
		[dict setObject:[NSNumber numberWithBool:isCache] forKey:@"cac"];
		if (error)
			[dict setObject:error forKey:@"err"];
		if (request)
			[dict setObject:request forKey:@"req"];
		
		[self performSelectorOnMainThread:@selector(requestEnconteredError:) withObject:dict waitUntilDone:YES];
	}
	
	if (!error || continueAftError) {
		
		[dict setObject:[NSNumber numberWithBool:isCache] forKey:@"cac"];
		if (error)
			[dict setObject:error forKey:@"err"];
		if (parsedObj)
			[dict setObject:parsedObj forKey:@"obj"];
		if (pagination)
			[dict setObject:pagination forKey:@"pag"];
		if (request)
			[dict setObject:request forKey:@"req"];
		
		[self performSelectorOnMainThread:@selector(requestHasFinished:) withObject:dict waitUntilDone:YES];
	}

}

- (void)requestHasFinished:(NSDictionary*)dict {
	if ([self.delegate respondsToSelector:@selector(epcWebService:returnedData:pagination:isCache:url:parseError:)]) {
		id data = [dict objectForKey:@"obj"];
		EPCPagination *pagination = [dict objectForKey:@"pag"];
		EPCHTTPRequest *request = [dict objectForKey:@"req"];
		NSError *error = [dict objectForKey:@"err"];
		BOOL isCache = [[dict objectForKey:@"cac"] boolValue];
		
		NSURL *url = request.url;
		if (!url) {
			url = request.urlRequest.URL;
		}
		
		[self.delegate epcWebService:self returnedData:data pagination:pagination isCache:isCache url:url parseError:error];
	}
	else {
		NSAssert(_delegate==nil, @"You forgot to implement the delegate for %@", NSStringFromClass([self class]));
	}
}

- (void)requestEnconteredError:(NSDictionary*)dict {
	if ([self.delegate respondsToSelector:@selector(epcWebService:encounteredError:parsingURL:)]) {
		NSError *error = [dict objectForKey:@"err"];
		EPCHTTPRequest *request = [dict objectForKey:@"req"];
		
		NSURL *url = request.url;
		if (!url) {
			url = request.urlRequest.URL;
		}
		
		[self.delegate epcWebService:self encounteredError:error parsingURL:url];
	}
	else {
		NSAssert(_delegate==nil, @"You forgot to implement the delegate for %@", NSStringFromClass([self class]));
	}
}

#pragma mark - Cache

+ (BOOL)deleteAllCaches {
	NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"EPCWSCache"];
	NSError *error = nil;
	NSFileManager *fm = [NSFileManager defaultManager];
	if ([fm fileExistsAtPath:path])
		[fm removeItemAtPath:path error:&error];
	else
		return NO;
	return (error == nil);
}

-(BOOL)deleteCache {
	NSError *error = nil;
	@synchronized(self) {
		NSString *path = [self cachePath];
		NSFileManager *fm = [NSFileManager defaultManager];
		if ([fm fileExistsAtPath:path]) {
			[fm removeItemAtPath:path error:&error];
		}
#ifdef DEBUG
		if (error)
			NSLog(@"%s Warning: Error while deleting cache folder (%@). %@", __PRETTY_FUNCTION__, path, error);
#endif
		_cachePath = nil;
	}
	return (error == nil);
}

-(void)deleteCacheForURLString:(NSString *)urlString {
	@synchronized(self) {
		NSString *key = [urlString md5];
		NSString *path = [[self cachePath] stringByAppendingFormat:@"/%@.txt", key];
		NSError *error = nil;
		NSFileManager *fm = [NSFileManager defaultManager];
		if ([fm fileExistsAtPath:path]) {
			[fm removeItemAtPath:path error:&error];
		}
#ifdef DEBUG
		if (error)
			NSLog(@"%s Warning: Error while deleting cache folder (%@). %@", __PRETTY_FUNCTION__, path, error);
#endif
	}
}

-(void)saveRequestToCache:(EPCHTTPRequest *)request {
	NSString *path = [self cachePath];
	if (!path)
		return;
	
	NSString *key = [[request.url absoluteString] md5];
	path = [path stringByAppendingFormat:@"/%@.txt", key];
	
	NSError *error = nil;
	
	if(![request.responseString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error]) {
#ifdef DEBUG
		NSLog(@"%s Warning: Error while writing file (%@). %@", __PRETTY_FUNCTION__, path, error);
#endif
	}
}

- (NSData*)cachedDataFromURLString:(NSString*)urlString {
	NSString *storePath = [self cachePath];
	if (!storePath)
		return nil;
	
	NSString *key = [urlString md5];
	NSString *path = [storePath stringByAppendingFormat:@"/%@.txt", key];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
		NSError *error = nil;
		NSData *data = [NSData dataWithContentsOfFile:path options:NSDataReadingUncached error:&error];
		if (error) {
#ifdef DEBUG
			NSLog(@"%s Warning: Error while trying to load cache file (%@). %@", __PRETTY_FUNCTION__, path, error);
#endif
			return nil;
		}
		return data;
	}
	
	return nil;
}

- (NSString*)cachePath {
	if (!_cachePath) {
		_cachePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"EPCWSCache/%@", NSStringFromClass([self class])]];
		NSFileManager *fm = [NSFileManager defaultManager];
		if (![fm fileExistsAtPath:_cachePath]) {
			NSError *error = nil;
			[fm createDirectoryAtPath:_cachePath withIntermediateDirectories:YES attributes:nil error:&error];
			if (error) {
#ifdef DEBUG
				NSLog(@"%s Warning: Error while trying to create cache folder (%@). %@", __PRETTY_FUNCTION__, _cachePath,error);
#endif
				_cachePath = nil;
			}
		}
	}
	return _cachePath;
}



#pragma mark - Override these

- (NSString*)webServiceURL {
	NSAssert(NO, @"Override this. %s", __PRETTY_FUNCTION__);
	return nil;
}

- (id)parseToObjectFromData:(NSData*)data pagination:(EPCPagination**)pagination error:(NSError**)error continueAfterError:(BOOL**)continueAfterError {
	if ([self class] != [EPCWebService class] && [self respondsToSelector:@selector(parseToObjectFromString:pagination:error:continueAfterError:)]) {
		// supporting older implementations
		NSString *string = [[NSString alloc] initWithData:data encoding:[self responseStringEncoding]];
		return [self parseToObjectFromString:string pagination:pagination error:error continueAfterError:continueAfterError];
	}
	else
		NSAssert(NO, @"Override this. %s", __PRETTY_FUNCTION__);
	
	return nil;
}

- (id)parseToObjectFromString:(NSString*)string pagination:(EPCPagination**)pagination error:(NSError**)error continueAfterError:(BOOL**)continueAfterError {
	NSAssert(NO, @"Deprecated. %s", __PRETTY_FUNCTION__);
	return nil;
}

#pragma mark - Optional Override

- (NSStringEncoding)responseStringEncoding {
	return NSUTF8StringEncoding;
}

#pragma mark - End Override
@end


@implementation EPCPagination
- (void)dealloc {
    self.previousURLString = nil;
	self.nextURLString = nil;
}
@end