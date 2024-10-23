//
// Created by TruVideo on 18/06/24.
// Copyright © 2024 TruVideo. All rights reserved.
//

import Foundation

extension ErrorReason {
    /// A struct that defines common network-related error reasons.
    public struct NetworkErrorReason {
        /// Error indicating that the authentication token could not be found.
        ///
        /// This error occurs when the system fails to retrieve the authentication token that is required to make
        /// authenticated network requests.
        public static let authenticationTokenNotFound = ErrorReason(
            rawValue: "com.truVideo.foundation.request.authentication.token.notFound"
        )
        
        /// Error indicating that the request or response interception failed.
        ///
        /// This error occurs when the network request or response is intercepted and the interception process fails.
        public static let interceptionFailed = ErrorReason(
            rawValue: "com.truVideo.foundation.request.interception.failed"
        )
        
        /// Error indicating that the URL used in the network request is invalid.
        ///
        /// This error occurs when the URL provided in the network request is not properly formatted or is not a valid URL.
        public static let invalidURL = ErrorReason(
            rawValue: "com.truVideo.foundation.invalid.url"
        )
        
        /// Error indicating that encoding of the request parameters failed.
        ///
        /// This error occurs when the parameters to be sent in a network request could not be properly encoded.
        public static let parameterEncodingFailed = ErrorReason(
            rawValue: "com.truVideo.foundation.parameter.encoding.failed"
        )
        
        /// Error indicating that serialization of the response data failed.
        ///
        /// This error occurs when the response data from the server could not be properly serialized into the expected format.
        public static let responseSerializationFailed = ErrorReason(
            rawValue: "com.truVideo.foundation.response.serialization.failed"
        )
    }
}
