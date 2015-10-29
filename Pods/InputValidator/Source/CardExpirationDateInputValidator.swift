import Foundation
import Validation

/*
    This input validator should validate strings with the following pattern:
    MM/YY, where MM is month and YY is year. MM shouldn't be more than 12 and year
    can be pretty much any number above the current year (this to ensure that the
    card is not expired).
*/
public struct CardExpirationDateInputValidator: Validatable {
    var validation: Validation

    public init(validation: Validation) {
        self.validation = validation
    }

    public func validateReplacementString(replacementString: String?, usingFullString fullString: String?, inRange range: NSRange?, exhaustive: Bool = false) -> Bool {
        let baseInputValidator = InputValidator(validation: self.validation)
        var valid = baseInputValidator.validateReplacementString(replacementString, usingFullString: fullString, inRange: range, exhaustive: exhaustive)
        if valid {
            let text = fullString ?? ""

            if let replacementString = replacementString, range = range {
                var composedString = baseInputValidator.composedString(replacementString, text: text, inRange: range)

                if composedString.characters.count > 0 {
                    var precomposedString = composedString
                    if composedString.characters.count == 4 || composedString.characters.count == 5 {
                        let index = composedString.startIndex.advancedBy("MM/".characters.count)
                        precomposedString = composedString.substringFromIndex(index)
                    }

                    let formatter = NSNumberFormatter()
                    let number = formatter.numberFromString(precomposedString)?.integerValue
                    if let number = number {
                        switch composedString.characters.count {
                        case 1:
                            valid = (number == 0 || number == 1)
                            break
                        case 2:
                            let maximumMonth = 12
                            valid = (number > 0 && number <= maximumMonth)
                            break
                        case 3:
                            let index = composedString.startIndex.advancedBy("MM".characters.count)
                            composedString = composedString.substringFromIndex(index)
                            valid = (composedString == "/")
                            break
                        case 4, 5:
                            let year = NSCalendar.currentCalendar().component(.Year, fromDate: NSDate())

                            let century = floor(Double(year) / 100.0)
                            let basicYear = Double(year) - (century * 100.0)
                            let decade = floor(basicYear / 10.0)

                            let isDecimal = (precomposedString.characters.count == 1)
                            let isYear = (precomposedString.characters.count == 2)
                            if isDecimal {
                                valid = number >= Int(decade)
                            } else if isYear {
                                valid = number >= Int(basicYear)
                            }

                            break
                        default:
                            break
                        }
                    }
                }
            }
        }

        return valid
    }
}
