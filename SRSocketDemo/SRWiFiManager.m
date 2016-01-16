//
//  SRWiFiManager.m
//  SRSocketDemo
//
//  Created by wangwendong on 16/1/15.
//  Copyright © 2016年 sunricher. All rights reserved.
//

#import "SRWiFiManager.h"
#import "GCDAsyncSocket.h"
#import "GCDAsyncUdpSocket.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <ifaddrs.h>
#import <arpa/inet.h>

@interface SRWiFiManager () <GCDAsyncSocketDelegate, GCDAsyncUdpSocketDelegate>

//@property (strong, nonatomic) GCDAsyncSocket *tcpSocket;
@property (strong, nonatomic) NSMutableDictionary<NSString *, GCDAsyncSocket *> *tcpSocketDictionary;
@property (strong, nonatomic) GCDAsyncUdpSocket *udpSocket;

@property (strong, nonatomic) SRWiFiManagerSendReceiver sendReceiver;

@property (strong, nonatomic) NSMutableDictionary<NSNumber *, NSString *> *receiverDictionary;

@property (nonatomic) NSUInteger reconnectTimes;

@end

@implementation SRWiFiManager
dispatch_queue_t wifiManagerQueue;

+ (instancetype)sharedInstance {
    static id instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        
        [instance setupDidInit];
    });
    
    return instance;
}

+ (BOOL)isWiFiConnected {
    NSString *wifiName = [SRWiFiManager getWiFiName];
    
    if (wifiName.length < 1) {
        
        NSLog(@"WiFi is not connected");
        return NO;
    } else {
        
        NSLog(@"WiFi is connected");
        return YES;
    }
}

- (void)connectTCPWithHost:(NSString *)host port:(NSUInteger)port {
    if (![SRWiFiManager isWiFiConnected]) {
        return;
    }
    
    GCDAsyncSocket *tcpSocket0 = _tcpSocketDictionary[host];
    
    if (tcpSocket0.isConnected) {
        return;
    }
    
    NSError *err;
    
    GCDAsyncSocket *tcpSocket1 = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:wifiManagerQueue];
    
    [tcpSocket1 connectToHost:host onPort:port error:&err];
    
    [_tcpSocketDictionary setObject:tcpSocket1 forKey:host];
}

- (void)connectUDPWithPort:(NSUInteger)port {
    if (![SRWiFiManager isWiFiConnected]) {
        return;
    }
    
    NSError *err;
    
    [self disconnectSocket];
    
    _udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:wifiManagerQueue];
    
    if (![_udpSocket enableBroadcast:YES error:&err]) {
        NSLog(@"enableBroadcast err %@", err);
        
        return;
    }

//    [self refreshHostForUDP];
//    [_udpSocket connectToHost:_hostForUDP onPort:SRWiFiUDPPort error:&err];
    
    if (![_udpSocket bindToPort:0 error:&err]) {
        NSLog(@"bindToPort UDP err %@", err);
        
        return;
    }
    
    if (![_udpSocket beginReceiving:&err]) {
        NSLog(@"beginReceiveing UDP err %@", err);
        
        return;
    }
    
    _connectType = SRWiFiManagerConnectTypeUDP;
}

- (void)disconnectSocket {
    if (_tcpSocketDictionary) {
        for (NSString *host in _tcpSocketDictionary) {
            GCDAsyncSocket *tcpSocket = _tcpSocketDictionary[host];
            
            if (tcpSocket.isConnected) {
                [tcpSocket disconnect];
            }
            
            tcpSocket = nil;
        }
    }
    
    if (_udpSocket) {
        [_udpSocket close];
    }
    
    _udpSocket = nil;
    
    _connectType = SRWiFiManagerConnectTypeDisconnected;
}

- (void)refreshHostForUDP {
    _hostForUDP = @"";
    
    if ([SRWiFiManager isWiFiConnected]) {
        NSString *ipAddress = [self wifiIPAddress];
        if (ipAddress.length > 1) {
            NSArray *ipAddressComponents = [ipAddress componentsSeparatedByString:@"."];
            
            if (ipAddressComponents.count >= 4) {
                NSMutableString *result = [NSMutableString string];
                
                for (int i = 0; i < ipAddressComponents.count - 1; i++) {
                    [result appendFormat:@"%@.", ipAddressComponents[i]];
                }
                
                [result appendString:@"255"];
                
                _hostForUDP = result;
            }
        }
    }
    
    NSLog(@"refresh host for udp %@", _hostForUDP);
}

- (void)sendData:(NSData *)data withType:(SRWiFiManagerConnectType)type times:(NSUInteger)times sendTag:(SRWiFiManagerSendDataTag)tag timeout:(NSInteger)timeout receiver:(SRWiFiManagerSendReceiver)receiver {
    _sendReceiver = receiver;
    
    if (!data) {
        return;
    }
    
    if (![SRWiFiManager isWiFiConnected]) {
        
        return;
    }
    
    switch (type) {
        case SRWiFiManagerConnectTypeTCP: {
            
            
            break;
        }
        case SRWiFiManagerConnectTypeUDP: {
            [self refreshHostForUDP];
            
            if (!_udpSocket) {
                NSLog(@"udp is null");
                
                break;
            }
            
            do {
                [_udpSocket sendData:data toHost:_hostForUDP port:SRWiFiUDPPort withTimeout:-1 tag:tag];
                
                times --;
            } while (times > 0);
        
            break;
        }
            
        default:
            break;
    }
}

+ (NSString *)getWiFiName
{
    NSString *wifiName = nil;
    
    CFArrayRef wifiInterfaces = CNCopySupportedInterfaces();
    
    if (!wifiInterfaces) {
        return nil;
    }
    
    NSArray *interfaces = (__bridge NSArray *)wifiInterfaces;
    
    for (NSString *interfaceName in interfaces) {
        CFDictionaryRef dictRef = CNCopyCurrentNetworkInfo((__bridge CFStringRef)(interfaceName));
        
        if (dictRef) {
            NSDictionary *networkInfo = (__bridge NSDictionary *)dictRef;
            NSLog(@"network info -> %@", networkInfo);
            wifiName = [networkInfo objectForKey:(__bridge NSString *)kCNNetworkInfoKeySSID];
            
            CFRelease(dictRef);
        }
    }
    
    CFRelease(wifiInterfaces);
    
    NSLog(@"wifiName %@", wifiName);
    
    return wifiName;
}

- (NSString *)wifiIPAddress {
    NSString *address = nil;
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

#pragma mark - ------- Private -------

- (void)setupDidInit {
    _receiverDictionary = [NSMutableDictionary dictionary];
    _wifiDevices = [NSMutableArray array];
    _tcpSocketDictionary = [NSMutableDictionary dictionary];
    
    wifiManagerQueue = dispatch_queue_create("SRWiFiManagerQueue", DISPATCH_QUEUE_CONCURRENT);
    
    _reconnectTimes = 3;
}

#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    _connectType = SRWiFiManagerConnectTypeTCP;
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {

}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    _connectType = SRWiFiManagerConnectTypeDisconnected;
}

#pragma mark - GCDAsyncUdpSocketDelegate

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address {
    _connectType = SRWiFiManagerConnectTypeUDP;
    
    NSLog(@"udp did connect to address %@", address);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError *)error {
    _connectType = SRWiFiManagerConnectTypeDisconnected;
    
    // Reconnect
    while (_reconnectTimes > 0 && sock.isClosed) {
        [self connectUDPWithPort:48899];
        
        _reconnectTimes --;
        
        NSLog(@"udp reconnect");
    }
    
    _reconnectTimes = 3;
    
    NSLog(@"udp did not connect err %@", error);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error {
    
    NSLog(@"udp did not send data with tag %d, err %@", (int)tag, error);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    NSString *dataString = [NSString stringWithCString:data.bytes encoding:NSASCIIStringEncoding];
    
    if (_sendReceiver) {
        _sendReceiver(dataString);
    }
    
    NSLog(@"udp did receive form address\n%@\n%@\nfilter%@",address, dataString, filterContext);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
    
    NSLog(@"udp did send data with tag %d", (int)tag);
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error {
    _connectType = SRWiFiManagerConnectTypeDisconnected;
    
    NSLog(@"udp did close with err %@", error);
}

@end
