# AutoCompleteTextField

[![CI Status](http://img.shields.io/travis/Neil Francis Ramirez Hipona/AutoCompleteTextField.svg?style=flat)](https://travis-ci.org/Neil Francis Ramirez Hipona/AutoCompleteTextField)
[![Version](https://img.shields.io/cocoapods/v/AutoCompleteTextField.svg?style=flat)](http://cocoapods.org/pods/AutoCompleteTextField)
[![License](https://img.shields.io/cocoapods/l/AutoCompleteTextField.svg?style=flat)](http://cocoapods.org/pods/AutoCompleteTextField)
[![Platform](https://img.shields.io/cocoapods/p/AutoCompleteTextField.svg?style=flat)](http://cocoapods.org/pods/AutoCompleteTextField)

## Features
- [x] Provides a subclass of UITextField that has suggestion from input
- [x] Data suggestion are provided by users
- [x] Has autocomplete input feature
- [x] Optimized and light weight


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

## Requirements
- iOS 8.0+ / Mac OS X 10.9+
- Xcode 7.2+

## Installation

AutoCompleteTextField is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "AutoCompleteTextField"
```

## Author

Neil Francis Ramirez Hipona, nferocious76@gmail.com

### About

This project was inpired by 'HTAutocompleteTextField' an Objc-C of the same feature.

## License

AutoCompleteTextField is available under the MIT license. See the [LICENSE](https://github.com/nferocious76/AutoCompleteTextField/blob/master/LICENSE) file for more info.
