# AutoCompleteTextField

[![CI Status](https://img.shields.io/badge/build-passed-brightgreen.svg)](https://img.shields.io/badge/build-passed-brightgreen.svg)
[![Version](https://img.shields.io/badge/pod-v0.1.4-blue.svg)](https://img.shields.io/badge/pod-v0.1.4-blue.svg)
[![License](https://img.shields.io/badge/Lisence-MIT-yellow.svg)](https://img.shields.io/badge/Lisence-MIT-yellow.svg)
[![Platform](https://img.shields.io/badge/platform-ios-lightgrey.svg)](https://img.shields.io/badge/platform-ios-lightgrey.svg)

## Features
- [x] Provides a subclass of UITextField that has suggestion from input
- [x] Data suggestion are provided by users
- [x] Has autocomplete input feature
- [x] Optimized and light weight


## Requirements

- iOS 8.0+ / Mac OS X 10.9+
- Xcode 7.2+


## Installation

AutoCompleteTextField is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "AutoCompleteTextField"
```

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

```Swift

// Subclass a TextField with 'AutoCompleteTextField'
let myTextField = AutoCompleteTextField(frame: CGRectMake(0, 0, 100, 30))

// Set dataSource, it can be setted from the XCode IB like TextFieldDelegate
myTextField.autoCompleteTextFieldDataSource = self

// Setting delimiter is optional. If setted, it will only look for suggestion if delimiter is found
myTextField.setDelimiter("@")

// Setting an autocompletion button with text field events
myTextField.showAutoCompleteButton(autoCompleteButtonViewMode: .WhileEditing)

// Then provide your data source to get the suggestion from inputs
func autoCompleteTextFieldDataSource(autoCompleteTextField: AutoCompleteTextField) -> [String] {
        
    return ["gmail.com", "hotmail.com", "domain.net"]
}

```

## Author

Neil Francis Ramirez Hipona, nferocious76@gmail.com

### About

This project was inpired by 'HTAutocompleteTextField' an Objc-C framework of the same feature.

## License

AutoCompleteTextField is available under the MIT license. See the [LICENSE](https://github.com/nferocious76/AutoCompleteTextField/blob/master/LICENSE) file for more info.
