import Foundation
import Validation

public struct DecimalInputValidator: Validatable {
    var validation: Validation

    public init(validation: Validation) {
        self.validation = validation
    }

    public func validateReplacementString(replacementString: String?, usingFullString fullString: String?, inRange range: NSRange?, exhaustive: Bool = false) -> Bool {
        let baseInputValidator = InputValidator(validation: self.validation)
        var valid = baseInputValidator.validateReplacementString(replacementString, usingFullString: fullString, inRange: range, exhaustive: exhaustive)
        if valid {
            if let fullString = fullString, replacementString = replacementString {
                let hasDelimiter = (fullString.containsString(",") || fullString.containsString("."))
                let replacementIsDelimiter = (replacementString == "," || replacementString == ".")
                if hasDelimiter && replacementIsDelimiter {
                    valid = false
                }
            }

            if let replacementString = replacementString {
                let floatSet = NSCharacterSet(charactersInString: "1234567890,")
                let stringSet = NSCharacterSet(charactersInString: replacementString)
                valid = floatSet.isSupersetOfSet(stringSet)
            }
        }
        
        return valid
    }
}
