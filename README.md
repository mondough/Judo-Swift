[![Cocoapods Compatible](https://img.shields.io/cocoapods/v/Judo.svg)](https://img.shields.io/cocoapods/v/Judo.svg)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/Judo.svg)](http://http://cocoadocs.org/docsets/Judo)
[![Platform](https://img.shields.io/cocoapods/p/Judo.svg)](http://http://cocoadocs.org/docsets/Judo)
[![Twitter](https://img.shields.io/badge/twitter-@JudoPayments-orange.svg)](http://twitter.com/JudoPayments)

# Judo Swift SDK #

This is the new Judo Swift SDK. It is currently in development and not functional. You can try it using Xcode 7 Beta and Swift 2.0


### What is this project for? ###

The Judo SDK is a framework to make accepting payments inside your app as easy and frictionless as possible.


## Integration

### Sign up for judopayments

- To use the Judo SDK, you'll need to [sign up](https://www.judopay.com/signup) and get your app token 
- the SDK has to be integrated in your project using one of the following methods

#### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects.

CocoaPods 0.36 adds supports for Swift and embedded frameworks. You can install it with the following command:

```bash
$ gem install cocoapods
```

add Judo to your `Podfile` to integrate it into your Xcode project:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

pod 'Judo', '~> 0.1.4'
```

Then, run the following command:

```bash
$ pod install
```


#### Carthage

[Carthage](https://github.com/Carthage/Carthage) - decentralized dependency management.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

- To integrate Judo into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
	git "https://git@bitbucket.org/judo/judo-swift.git" >= 0.1.4
```

- On your application targets’ “General” settings tab, in the “Linked Frameworks and Libraries” section, drag and drop each framework you want to use from the Carthage/Build folder on disk.
- On your application targets’ “Build Phases” settings tab, click the “+” icon and choose “New Run Script Phase”. Create a Run Script with the following contents:

```sh
/usr/local/bin/carthage copy-frameworks
```

and add the paths to the frameworks you want to use under “Input Files”, e.g.:

```
$(SRCROOT)/Carthage/Build/iOS/Judo.framework
```

### Manual Integration

Uou can integrate Judo into your project manually if you prefer not to use dependency management.

#### Adding the Framework

- Add Judo as a [submodule](http://git-scm.com/docs/git-submodule) by opening the Terminal, changing into your project directory, and entering the following command:

```bash
$ git submodule add https://bitbucket.org/judo/judo-swift Judo
```

- Open the new `Judo` folder, and drag the `Judo.xcodeproj` into the Project Navigator of your application's Xcode project.
- Select the `Judo.xcodeproj` in the Project Navigator and verify the deployment target matches that of your application target.
- Next, select your application project in the Project Navigator (blue project icon) to navigate to the target configuration window and select the application target under the "Targets" heading in the sidebar.
- In the tab bar at the top of that window, open the "General" panel.
- Click on the `+` button under the "Embedded Binaries" section.
- You will see two different `Judo.xcodeproj` folders each with two different versions of the `Judo.framework` nested inside a `Products` folder.
- Select the top `Judo.framework` for iOS and the bottom one for OS X.


### Further Setup

- add `import Judo` to the top of the file where you want to use the SDK.

- To instruct the SDK to communicate with the sandbox, include the following line  `Judo.sandboxed = true` When you are ready to go live you can remove this line. We would recommend to put this in the method `didFinishLaunchingWithOptions` in your AppDelegate

- You can also set your key and secret here if you do not wish to include it in all subsequent calls `Judo.setToken(token:, secret:)`


### Examples

#### Token and Secret
the token and secret are accessible from your JudoPay Account [here](https://portal.judopay.com/Developer) after you have created an App and either generated sandbox or live tokens. We recommend you to set this in your AppDelegate in the `didFinishLaunchingWithOptions` method

```swift
let token = "a3xQdxP6iHdWg1zy"
let secret = "2094c2f5484ba42557917aad2b2c2d294a35dddadb93de3c35d6910e6c461bfb"

// Judo.didSetTokenAndSecret() returns false

Judo.setToken(token, secret: secret)

// Judo.didSetTokenAndSecret() returns true
```

#### Make a simple Payment

The Judo Swift SDK takes a reactive approach

##### Card Payment

```swift
let judoID = "100111222"
let references = Reference(yourConsuerReference: "consumer0053252", yourPaymentReference: "payment123asd", yourPaymentMetaData: nil)
let address = Address(line1: "242 Acklam Road", line2: "Westbourne Park", line3: nil, town: "London", postCode: "W10 5JJ")
let card = Card(number: "4976000000003436", expiryDate: "12/15", cv2: "452", address: address)
let amount = Amount(30)
let emailAddress = "hans@email.com"
let mobileNumber = "07100000000"

let location = CLLocationCoordinate2D(latitude: 0, longitude: 65)

let expectation = self.expectationWithDescription("payment expectation")

do {
	let makePayment = try Judo.payment(correctJudoID, amount: amount, reference: references)
								.card(card)
								.location(location)
								.contact(mobileNumber, emailAddress)
								.completion({ (data, error) -> () in
									if let _ = error {
										// failure
									} else {
										// success
									}
								})
} catch {
	// error creating a Transaction e.g. the judoID could be in a wrong format
}
```

##### Token Payment
```swift
Judo.payment(correctJudoID, amount: amount, reference: references)
	.paymentToken(payToken)
	.location(location)
	.contact(mobileNumber, emailAddress)
	.completion({ (data, error) -> () in
		if let _ = error {
			// failure
		} else {
			// success
		}
	})
```

notice that the only difference is calling `.paymentToken(payToken)` with a valid `PaymentToken` instead of `.card(card)` for making a token payment instead of a card payment. This process is the same for preAuths and Token preAuths

##### Card PreAuth

```
Judo.preAuth(correctJudoID, amount: amount, reference: references)
	.card(card)
	.location(location)
	.contact(mobileNumber, emailAddress)
	.completion({ (data, error) -> () in
		if let _ = error {
			// error
		} else {
			// success
		}
	})
```

##### Token PreAuth

```
Judo.preAuth(correctJudoID, amount: amount, reference: references)
	.paymentToken(payToken)
	.location(location)
	.contact(mobileNumber, emailAddress)
	.completion({ (data, error) -> () in
		if let _ = error {
			// error
		} else {
			// success
		}
	})
```

### Contribution guidelines

This SDK is being developed with a full TDD approach to reach 100% Test coverage

![TDD-Workflow](https://upload.wikimedia.org/wikipedia/commons/9/9c/Test-driven_development.PNG)

### License

Judo-Swift is released under the MIT license. See LICENSE for details.

### finished

* Card Payment
* Card PreAuth
* Token Payment
* Token PreAuth
* Receipts
* Collection
* Refund
* CocoaPods
* Carthage
* git submodule integration

### to do

* Pagination
* Types as Responses instead of JSONDictionary
* Example App

### Contact

* Ben Riazy
* Ben King