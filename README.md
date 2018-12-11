# Hawaii


## Getting Started

These instructions will get you a copy of the project up and running on your
local machine for development and testing purposes.

### Requirements

* iOS 10.0+/macOS 10.12
* Xcode 9.4.+
* Swift 4.2.+
* Cocoapods

### Installing

A step by step series of examples that tell you have to get a development env
running.

1. Clone the project from github - https://github.com/execom-eu/hawaii_mobile_ios.git
    * $ git clone https://github.com/execom-eu/hawaii_mobile_ios.git
    * $ cd hawaii_mobile_ios
    * $ pod install
    * $ git submodule init
    * $ git submodule update
    * $ cd ec-foundation-ios
    * $ git checkout swift_4
    * $ cd ..
    * $ git checkout master
    * $ Select Hawaii production/Hawaii Staging based on your preffrences or add new scheme if it does not exist
    * $ Run :)
2. If submodule missing for any reason you can clone it from here -
   https://gitlab.com/anovakovic/ec-foundation-ios. Open *Hawaii.xcworkspace* in
   Xcode. Drag *ECFoundation.xcodeproj* file from ECFoundation folder to Xcode.
3. Open Hawaii in Xcode project navigator. In General tab, scroll down to Embedded
   Binaries and add *ECFoundationiOS.framework*. You should be able to build
   application now.
4. If you still have some problems running application, try to reinstall pods.
   Open Terminal, navigate to project folder and run *pod install*

## Deployment

The main branch is only for development of the generic functions. No real
implementation of the app should be done on the main branch. For real application
implementation use different branches such as develop.
If you make any changes and want to deploy it on TestFlight, please open Hawaii in
Xcode project navigator, General tab, section Identity, and increment the build
number (and version if needed), also don't forget to increase build number 
and version number in two main extensions(RequestNotification and RequestServiceNotification). 
It is recommended that version number and build number in these extensions are in sync with project version and build number.
