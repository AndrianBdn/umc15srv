# UA Mobile Challange 2015 Final Stage Task 

This is a public version of the task that I've prepared for UA Mobile Challange 2015 final stage (junior section). 

The participants were given six hours to implement the solution. Using of third-party dependencies were not allowed. 

## The Task 

Develop univeral(iPhone, iPad) app  — an Mac-application management dashboard. 

The app should connect to the special HTTP-server (included with the task, see below) which runs on your Mac and provides 
 the list of currently running Mac applications (with name, icon, activity flag and time since launch).

The mobile app should update this data every 10 seconds and display it in the following way: 

- All applications should be displayed on the screen.
- Currently active (foreground) application should be displayed in the center of the screen. It's icon should be larger then the rest.
- Other application's icons should be located around it, the distance on the circumference between the icons should be the same.
- Changing of the active application should be displayed animated (by moving and resizing icons)
- Changes of the set of Mac-applications should be animated too. 

Tapping an app's icon should switch active application on the Mac. 

Bonus points: Implement two sorting options — by app name or by the time of application launch.  


# Mac Server for UA Mobile Challange 2015 

## Server application

The server is command line foreground Mac application, developed on 10.11.

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

### Errors 

HTTP status codes are used to indicate errors. 

### GET /apps 

Response is JSON, array of dictionaries. 

### GET /apps/[pid]/icon/[size].png

[size] is PNG image size (the resulting image would be square)

### POST /apps/[pid]/activate


