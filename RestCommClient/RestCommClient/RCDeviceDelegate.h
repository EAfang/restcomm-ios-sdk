//
//  RCDeviceDelegate.h
//  RestCommClient
//
//  Created by Antonis Tsakiridis on 7/13/14.
//  Copyright (c) 2014 TeleStax. All rights reserved.
//

/** @file RCDeviceDelegate.h */

@class RCDevice;
@class RCConnection;
@class RCPresenceEvent;

/**
 *  RCDevice notifies its delegate for RCDevice related events defined in this delegate protocol
 */
@protocol RCDeviceDelegate<NSObject>

@required
/**
 *  @abstract RCDevice stopped listening for incoming connections (**Not Implemented yet**)
 *
 *  @param device Device of interest
 *  @param error  The reason it stopped
 */
- (void)device:(RCDevice*)device didStopListeningForIncomingConnections:(NSError*)error;

@optional
/**
 *  @abstract RCDevice started listening for incoming connections (**Not Implemented yet**)
 *
 *  @param device Device of interest
 */
- (void)deviceDidStartListeningForIncomingConnections:(RCDevice*)device;

/**
 *  @abstract RCDevice received incoming connection
 *
 *  @param device     Device of interest
 *  @param connection Newly established connection
 */
- (void)device:(RCDevice*)device didReceiveIncomingConnection:(RCConnection*)connection;

/**
 *  @abstract RCDevice received presence update (**Not implemented yet**)
 *
 *  @param device        Device of interest
 *  @param presenceEvent Presence event
 */
- (void)device:(RCDevice *)device didReceivePresenceUpdate:(RCPresenceEvent *)presenceEvent;

/**
 *  @abstract RCDevice received incoming instant message
 *
 *  @param device  Device of interest
 *  @param message Instant message text
 */
- (void)device:(RCDevice *)device didReceiveIncomingMessage:(NSString *)message;
@end
