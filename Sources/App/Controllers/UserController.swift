// 

import Vapor
import Authentication
import Crypto
import Validation
import ContentaUserModel

struct UserController<D>: RouteCollection where D: JoinSupporting {
    typealias Database = D

    func boot(router: Router) throws {
        let usersRoute = router.grouped("api", "users")
        usersRoute.get(use: getAllHandler)
        usersRoute.get(User<Database>.parameter, use: getHandler)

        let basicAuthMiddleware = User<Database>.basicAuthMiddleware(using: BCryptDigest())
        let basicAuthGroup = usersRoute.grouped(basicAuthMiddleware)
        basicAuthGroup.post("login", use: loginHandler)

        let registerRoute = router.grouped("api", "register")
        registerRoute.post(use: registerHandler)
    }

    func getAllHandler(_ req: Request) throws -> Future<[User<Database>.Public]> {
        return User<Database>.query(on: req).decode(data: User<Database>.Public.self).all()
    }

    func getHandler(_ req: Request) throws -> Future<User<Database>.Public> {
        let user : Future<User<Database>> = try req.parameters.next(User<Database>.self)
        return user.convertToPublic()
    }

    func registerHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.content.decode(User<Database>.self).flatMap { user in
            // ensure username is unique
            /// let d1 = networkRequest(args).future()
            /// let d2 = d1.then { t -> EventLoopFuture<U> in
            ///     . . . something with t . . .
            ///     return netWorkRequest(args)
            /// }
            /// d2.whenSuccess { u in
            ///     NSLog("Result of second request: \(u)")
            /// }
            return try User<Database>.forUsernameOrEmail(username: user.username, email: user.email, on: req)
                .map { existingUsers in
                    if existingUsers.count > 0 {
                        throw Abort(.badRequest)
                    }
                }
                .then { t -> Future<User<Database>> in
                    return user.save(on: req)
                }
                .transform(to: HTTPResponseStatus.created)
            
//            return existingUsers.flatMap { result in
//                if let _ = result {
//                    return Future.map(on: req) { _ in
//                        return req.redirect(to: "/register")
//                    }
//                }
//                user.password = try BCryptDigest().hash(user.password)
//            }
        }
    }

    func loginHandler(_ req: Request) throws -> Future<User<Database>> {
        let user = try req.requireAuthenticated(User<Database>.self)
//        let token = try AccessToken<Database>.generate(for: user)
        user.failedLogins = 0
        user.lastLogin = Date()
        return user.save(on: req)
    }
}

