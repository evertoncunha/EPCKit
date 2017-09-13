//
//  EPCHTTPRequest.m
//
//  Created by Everton Cunha on 17/08/12.
//

#import "EPCHTTPRequest.h"

@interface EPCHTTPRequest() <NSURLConnectionDelegate, NSURLConnectionDataDelegate> {
	NSURLConnection *_urlConnection;
	NSString *_responseString;
	NSMutableData *_mutableData;
}
@end

@implementation EPCHTTPRequest
+ (EPCHTTPRequest*)requestWithRequest:(NSURLRequest *)urlRequest delegate:(id<EPCHTTPRequestDelegate>)delegate {
	EPCHTTPRequest *me = [[self alloc] initWithURLRequest:urlRequest delegate:delegate];
	return me;
}
+ (EPCHTTPRequest*)requestWithURL:(NSURL *)url delegate:(id<EPCHTTPRequestDelegate>)delegate {
	EPCHTTPRequest *me = [[self alloc] initWithURL:url delegate:delegate];
	return me;
}
+ (EPCHTTPRequest*)startRequestWithURL:(NSURL *)url delegate:(id<EPCHTTPRequestDelegate>)delegate {
	EPCHTTPRequest *me = [self requestWithURL:url delegate:delegate];
	[me startAsynchronous];
	return me;
}
- (id)initWithURL:(NSURL *)url delegate:(id<EPCHTTPRequestDelegate>)delegate {
	self = [super init];
	if (self) {
		self.url = url;
		self.delegate = delegate;
	}
	return self;
}
- (id)initWithURLRequest:(NSURLRequest *)urlRequest delegate:(id<EPCHTTPRequestDelegate>)delegate {
	self = [super init];
	if (self) {
		self.urlRequest = urlRequest;
		self.delegate = delegate;
	}
	return self;
}
- (void)dealloc
{
	self.url = nil;
	self.delegate = nil;
	self.error = nil;
	self.urlRequest = nil;
	_responseString = nil;
	_responseData = nil;
	[_urlConnection cancel];
	_urlConnection = nil;
}
- (void)clearDelegatesAndCancel {
	self.delegate = nil;
	[_urlConnection cancel];
	_urlConnection = nil;
}
- (void)startAsynchronous {
	NSAssert(_url || _urlRequest, @"%@ %s no URL or NSURLRequest to start the request.", NSStringFromClass([self class]), __PRETTY_FUNCTION__);
	
	if (_url || _urlRequest) {
		[_urlConnection cancel];
		_urlConnection = nil;
	}
	
	NSURLRequest *req = _urlRequest;
	
	if (!req) {
		req = [[NSURLRequest alloc] initWithURL:_url];
	}
	
	_mutableData = nil;
	_urlConnection = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
	
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	if (!_mutableData) {
		[self epcHTTPRequestStarted:self];
		_mutableData = [[NSMutableData alloc] init];
	}
	[_mutableData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	_responseData = _mutableData;
	[self epcHTTPRequestFinished:self];
	_mutableData = nil;
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	_mutableData = nil;
	self.error = error;
	[self epcHTTPRequestFailed:self];
}

- (void)epcHTTPRequestStarted:(EPCHTTPRequest*)request {
	if ([_delegate respondsToSelector:@selector(epcHTTPRequestStarted:)])
		[_delegate epcHTTPRequestStarted:self];
}
- (void)epcHTTPRequestFinished:(EPCHTTPRequest*)request {
	_responseString = nil;
	_responseData = request.responseData;
	if ([_delegate respondsToSelector:@selector(epcHTTPRequestFinished:)])
		[_delegate epcHTTPRequestFinished:self];
}
- (void)epcHTTPRequestFailed:(EPCHTTPRequest*)request {
	_responseString = nil;
	self.error = request.error;
	if ([_delegate respondsToSelector:@selector(epcHTTPRequestFailed:)])
		[_delegate epcHTTPRequestFailed:self];
}
- (NSString *)responseString {
	if (!_responseString && _responseData) {
		if (_responseStringEncoding == 0)
			_responseStringEncoding = NSUTF8StringEncoding;
		_responseString = [[NSString alloc] initWithData:_responseData encoding:_responseStringEncoding];
	}
	return _responseString;
}
- (void)startSynchronous {
	BOOL isDone = NO;
	if (_url) {
		while (![self isCancelled] && !isDone) {
			if ([_delegate respondsToSelector:@selector(epcHTTPRequestStarted:)])
				[(EPCHTTPRequest*)_delegate performSelectorOnMainThread:@selector(epcHTTPRequestStarted:) withObject:self waitUntilDone:YES];
			if ([self isCancelled])
				break;
			NSError *error = nil;
			_responseData = [[NSData alloc] initWithContentsOfURL:_url options:NSDataReadingUncached error:&error];
			self.error = error;
			if ([self isCancelled])
				break;
			if (_responseData && !_error) {
				if ([_delegate respondsToSelector:@selector(epcHTTPRequestFinished:)])
					[(EPCHTTPRequest*)_delegate performSelectorOnMainThread:@selector(epcHTTPRequestFinished:) withObject:self waitUntilDone:YES];
			}
			else {
				if ([_delegate respondsToSelector:@selector(epcHTTPRequestFailed:)])
					[(EPCHTTPRequest*)_delegate performSelectorOnMainThread:@selector(epcHTTPRequestFailed:) withObject:self waitUntilDone:YES];
			}
			isDone = YES;
		}
	}
	else if (_urlRequest) {
		while (![self isCancelled] && !isDone) {
			if ([_delegate respondsToSelector:@selector(epcHTTPRequestStarted:)])
				[(EPCHTTPRequest*)_delegate performSelectorOnMainThread:@selector(epcHTTPRequestStarted:) withObject:self waitUntilDone:YES];
			if ([self isCancelled])
				break;
			NSError *error = nil;
			_responseData = [NSURLConnection sendSynchronousRequest:_urlRequest returningResponse:nil error:&error];
			self.error = error;
			if ([self isCancelled])
				break;
			if (_responseData && !_error) {
				if ([_delegate respondsToSelector:@selector(epcHTTPRequestFinished:)])
					[(EPCHTTPRequest*)_delegate performSelectorOnMainThread:@selector(epcHTTPRequestFinished:) withObject:self waitUntilDone:YES];
			}
			else {
				if ([_delegate respondsToSelector:@selector(epcHTTPRequestFailed:)])
					[(EPCHTTPRequest*)_delegate performSelectorOnMainThread:@selector(epcHTTPRequestFailed:) withObject:self waitUntilDone:YES];
			}
			isDone = YES;
		}
	}
}

- (void)main {
	[self startSynchronous];
}
- (void)cancel {
	@synchronized(self) {
		_delegate = nil;
	}
	self.delegate = nil;
	[_urlConnection cancel];
	_urlConnection = nil;
	[super cancel];
}
@end
