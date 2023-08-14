import Foundation

public struct AppError: LocalizedError {
    let message: String

    public var errorDescription: String? { return message }
}
