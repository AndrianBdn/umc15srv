# Mac Server for UA Mobile Challange 2015 

## Building from Source Code 

- Check out git repository 
- Run 'pod install' (make sure you have CocoaPods)
- Run in Xcode 

## Connecting 

The server listens on 9091 TCP port. 

## Bonjour

The server advertises Bonjour service "_mch15._tcp." 


## API 

### Authorization 

The server uses [RFC 6750 Section 2.1](https://tools.ietf.org/html/rfc6750#section-2.1)-style authorization. Bearer token is output on server start. 


### GET /apps 

Response is JSON, array of dictionaries. 

### GET /apps/[pid]/icon/[size].png

[size] is png image size (the resulting image would be square)

### POST /apps/[pid]/activate


