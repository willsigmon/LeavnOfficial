import Foundation

// MARK: - Array Extension

extension Array {
    /// Splits an array into chunks of a specified size.
    /// - Parameter size: The size of each chunk.
    /// - Returns: An array of arrays, each containing a chunk of the original.
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
