//
// Created by TruVideo on 7/10/24.
// Copyright © 2024 TruVideo. All rights reserved.
//

import Foundation

extension Error {
    /// Converts the current error to a NetworkError if possible, otherwise returns a default NetworkError
    /// - Parameter defaultError: A closure that produces a default NetworkError if the conversion fails
    /// - Returns: The current error as a NetworkError, or the provided default NetworkError
    func asFoundationError(or defaultError: @autoclosure () -> TruVideoFoundationError) -> TruVideoFoundationError {
        self as? TruVideoFoundationError ?? defaultError()
    }
}
