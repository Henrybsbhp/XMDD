# Validation

A simple type to perform validations on Strings.

#### Maximum or/and minimum length

```swift
var validation = Validation()
validation.minimumLength = 5
validation.maximumLength = 6

validation.validateString("1234") // => returns false
validation.validateString("12345") // => returns true
validation.validateString("1234567") // => returns false
```

#### Minimum or/and maximum value

```swift
var validation = Validation()
validation.minimumValue = 5
validation.maximumValue = 6

validation.validateString("4") // => returns false
validation.validateString("5") // => returns true
validation.validateString("7") // => returns false
```

#### Required (short hand for minimum value: 1)

```swift
var validation = Validation()
validation.required = true

validation.validateString("12345") // => returns true
validation.validateString("") // => returns false
```

#### Format (regex)

```swift
var validation = Validation()
validation.format = "[\\w._%+-]+@[\\w.-]+\\.\\w{2,}"

validation.validateString("elvisnunez@me.co") // => returns true
validation.validateString("elvnume.co") // => returns false
validation.validateString("hi there elvisnunez@me.com") // => returns false
```

#### API

Making exhaustive `false` will cause `minimumLength`, `minimumValue` and `format` to be ignored this is useful for partial validations, or validations where the final string is in process of been completed. For example when entering characters into an UITextField. With exhaustive `true` all validations will be run.

```swift
public func validateString(string: String, exhaustive: Bool = true) -> Bool
```

## Installation

**Validation** is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Validation'
```

## License

**Validation** is available under the MIT license. See the LICENSE file for more info.

## Author

Elvis Nuñez, [@3lvis](https://twitter.com/3lvis)
