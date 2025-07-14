import Foundation

// MARK: - String Validation Extensions
public extension String {
    
    // MARK: - Basic Validations
    /// Check if string is empty or contains only whitespace
    var isBlank: Bool {
        self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /// Check if string is not empty and not just whitespace
    var isNotBlank: Bool {
        !isBlank
    }
    
    /// Trimmed version of the string
    var trimmed: String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Check if string contains only letters
    var isAlphabetic: Bool {
        !isEmpty && range(of: "[^a-zA-Z]", options: .regularExpression) == nil
    }
    
    /// Check if string contains only numbers
    var isNumeric: Bool {
        !isEmpty && range(of: "[^0-9]", options: .regularExpression) == nil
    }
    
    /// Check if string contains only alphanumeric characters
    var isAlphanumeric: Bool {
        !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }
    
    // MARK: - Email Validation
    /// Validate email format
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }
    
    // MARK: - Phone Number Validation
    /// Validate phone number format (basic international format)
    var isValidPhoneNumber: Bool {
        let phoneRegex = "^[+]?[(]?[0-9]{1,3}[)]?[-\\s\\.]?[(]?[0-9]{1,3}[)]?[-\\s\\.]?[0-9]{3,5}[-\\s\\.]?[0-9]{4,6}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: self)
    }
    
    /// Format phone number for display
    var formattedPhoneNumber: String {
        let cleanNumber = self.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        if cleanNumber.count == 10 { // US format
            let mask = "(XXX) XXX-XXXX"
            return applyMask(mask, to: cleanNumber)
        } else if cleanNumber.count == 11 && cleanNumber.hasPrefix("1") { // US with country code
            let number = String(cleanNumber.dropFirst())
            let mask = "+1 (XXX) XXX-XXXX"
            return applyMask(mask, to: number)
        }
        
        return self
    }
    
    // MARK: - Password Validation
    /// Validate password strength
    func isValidPassword(
        minLength: Int = 8,
        requireUppercase: Bool = true,
        requireLowercase: Bool = true,
        requireDigit: Bool = true,
        requireSpecialCharacter: Bool = true
    ) -> Bool {
        guard count >= minLength else { return false }
        
        if requireUppercase && range(of: "[A-Z]", options: .regularExpression) == nil {
            return false
        }
        
        if requireLowercase && range(of: "[a-z]", options: .regularExpression) == nil {
            return false
        }
        
        if requireDigit && range(of: "[0-9]", options: .regularExpression) == nil {
            return false
        }
        
        if requireSpecialCharacter && range(of: "[!@#$%^&*(),.?\":{}|<>]", options: .regularExpression) == nil {
            return false
        }
        
        return true
    }
    
    /// Get password strength level
    var passwordStrength: PasswordStrength {
        if count < 6 {
            return .weak
        }
        
        var strength = 0
        
        if count >= 8 { strength += 1 }
        if count >= 12 { strength += 1 }
        if range(of: "[A-Z]", options: .regularExpression) != nil { strength += 1 }
        if range(of: "[a-z]", options: .regularExpression) != nil { strength += 1 }
        if range(of: "[0-9]", options: .regularExpression) != nil { strength += 1 }
        if range(of: "[!@#$%^&*(),.?\":{}|<>]", options: .regularExpression) != nil { strength += 1 }
        
        switch strength {
        case 0...2:
            return .weak
        case 3...4:
            return .medium
        default:
            return .strong
        }
    }
    
    // MARK: - URL Validation
    /// Check if string is a valid URL
    var isValidURL: Bool {
        guard let url = URL(string: self) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
    
    /// Convert to URL if valid
    var toURL: URL? {
        URL(string: self)
    }
    
    // MARK: - Name Validation
    /// Validate name (allows letters, spaces, hyphens, and apostrophes)
    var isValidName: Bool {
        let nameRegex = "^[a-zA-Z\\s'-]+$"
        let namePredicate = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        return namePredicate.evaluate(with: self)
    }
    
    /// Get initials from name
    var initials: String {
        let components = self.components(separatedBy: .whitespaces)
        let initials = components.compactMap { $0.first?.uppercased() }
        return initials.prefix(2).joined()
    }
    
    // MARK: - Credit Card Validation
    /// Basic credit card number validation using Luhn algorithm
    var isValidCreditCard: Bool {
        let cleanNumber = self.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        guard cleanNumber.count >= 13 && cleanNumber.count <= 19 else {
            return false
        }
        
        return luhnCheck(cleanNumber)
    }
    
    /// Format credit card number for display
    var formattedCreditCard: String {
        let cleanNumber = self.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        var formatted = ""
        for (index, character) in cleanNumber.enumerated() {
            if index > 0 && index % 4 == 0 {
                formatted += " "
            }
            formatted.append(character)
        }
        
        return formatted
    }
    
    // MARK: - Date Validation
    /// Check if string matches date format
    func isValidDate(format: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.date(from: self) != nil
    }
    
    /// Convert string to date using format
    func toDate(format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.date(from: self)
    }
    
    // MARK: - Leave Request Validation
    /// Validate leave reason (minimum length and not just whitespace)
    func isValidLeaveReason(minLength: Int = 10) -> Bool {
        let trimmedReason = self.trimmed
        return trimmedReason.count >= minLength
    }
    
    /// Validate employee ID format (customizable)
    func isValidEmployeeID(pattern: String = "^[A-Z]{2}[0-9]{4}$") -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
        return predicate.evaluate(with: self)
    }
    
    // MARK: - Sanitization
    /// Remove HTML tags
    var htmlStripped: String {
        self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
    }
    
    /// Escape for SQL queries
    var sqlEscaped: String {
        self.replacingOccurrences(of: "'", with: "''")
    }
    
    /// Remove non-alphanumeric characters
    var alphanumericOnly: String {
        self.components(separatedBy: CharacterSet.alphanumerics.inverted).joined()
    }
    
    // MARK: - Formatting Helpers
    /// Capitalize first letter of each word
    var titleCased: String {
        self.lowercased()
            .split(separator: " ")
            .map { $0.prefix(1).uppercased() + $0.dropFirst() }
            .joined(separator: " ")
    }
    
    /// Convert to camelCase
    var camelCased: String {
        let words = self.components(separatedBy: CharacterSet.alphanumerics.inverted)
        guard let firstWord = words.first else { return self }
        
        let remainingWords = words.dropFirst().map { $0.prefix(1).uppercased() + $0.dropFirst().lowercased() }
        return firstWord.lowercased() + remainingWords.joined()
    }
    
    /// Convert to snake_case
    var snakeCased: String {
        self.replacingOccurrences(of: "([A-Z])", with: "_$1", options: .regularExpression)
            .lowercased()
            .trimmingCharacters(in: CharacterSet(charactersIn: "_"))
    }
    
    // MARK: - Private Helpers
    private func applyMask(_ mask: String, to string: String) -> String {
        var result = ""
        var stringIndex = string.startIndex
        
        for char in mask {
            if char == "X" {
                if stringIndex < string.endIndex {
                    result.append(string[stringIndex])
                    stringIndex = string.index(after: stringIndex)
                }
            } else {
                result.append(char)
            }
        }
        
        return result
    }
    
    private func luhnCheck(_ number: String) -> Bool {
        var sum = 0
        let digitStrings = number.reversed().map { String($0) }
        
        for (index, digitString) in digitStrings.enumerated() {
            guard let digit = Int(digitString) else { return false }
            
            if index % 2 == 1 {
                let doubled = digit * 2
                sum += doubled > 9 ? doubled - 9 : doubled
            } else {
                sum += digit
            }
        }
        
        return sum % 10 == 0
    }
}

// MARK: - Supporting Types
public enum PasswordStrength {
    case weak
    case medium
    case strong
    
    var color: String {
        switch self {
        case .weak:
            return "red"
        case .medium:
            return "orange"
        case .strong:
            return "green"
        }
    }
    
    var description: String {
        switch self {
        case .weak:
            return "Weak"
        case .medium:
            return "Medium"
        case .strong:
            return "Strong"
        }
    }
}

// MARK: - Validation Result
public struct ValidationResult {
    public let isValid: Bool
    public let errorMessage: String?
    
    public init(isValid: Bool, errorMessage: String? = nil) {
        self.isValid = isValid
        self.errorMessage = errorMessage
    }
}

// MARK: - Field Validator
public struct FieldValidator {
    public static func validate(
        email: String
    ) -> ValidationResult {
        if email.isBlank {
            return ValidationResult(isValid: false, errorMessage: "Email is required")
        }
        if !email.isValidEmail {
            return ValidationResult(isValid: false, errorMessage: "Invalid email format")
        }
        return ValidationResult(isValid: true)
    }
    
    public static func validate(
        password: String,
        confirmPassword: String? = nil
    ) -> ValidationResult {
        if password.isBlank {
            return ValidationResult(isValid: false, errorMessage: "Password is required")
        }
        if !password.isValidPassword() {
            return ValidationResult(isValid: false, errorMessage: "Password must be at least 8 characters with uppercase, lowercase, number, and special character")
        }
        if let confirmPassword = confirmPassword, password != confirmPassword {
            return ValidationResult(isValid: false, errorMessage: "Passwords do not match")
        }
        return ValidationResult(isValid: true)
    }
    
    public static func validate(
        phoneNumber: String
    ) -> ValidationResult {
        if phoneNumber.isBlank {
            return ValidationResult(isValid: false, errorMessage: "Phone number is required")
        }
        if !phoneNumber.isValidPhoneNumber {
            return ValidationResult(isValid: false, errorMessage: "Invalid phone number format")
        }
        return ValidationResult(isValid: true)
    }
    
    public static func validate(
        name: String,
        fieldName: String = "Name"
    ) -> ValidationResult {
        if name.isBlank {
            return ValidationResult(isValid: false, errorMessage: "\(fieldName) is required")
        }
        if !name.isValidName {
            return ValidationResult(isValid: false, errorMessage: "\(fieldName) can only contain letters, spaces, hyphens, and apostrophes")
        }
        return ValidationResult(isValid: true)
    }
}