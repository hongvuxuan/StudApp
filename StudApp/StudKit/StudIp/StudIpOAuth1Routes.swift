//
//  StudIpOAuth1Routes.swift
//  StudKit
//
//  Created by Steffen Ryll on 31.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

struct StudIpOAuth1Routes: OAuth1Routes {
    static let requestToken = StudIpOAuth1Routes(path: "../dispatch.php/api/oauth/request_token", method: .post)

    static var authorize = StudIpOAuth1Routes(path: "../dispatch.php/api/oauth/authorize", method: .get)

    static var accessToken = StudIpOAuth1Routes(path: "../dispatch.php/api/oauth/access_token", method: .post)

    let path: String

    let method: HttpMethods
}
