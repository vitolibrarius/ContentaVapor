// 

import Vapor
import Authentication
import Crypto
import Validation
import ContentaUserModel

struct UserController<D>: RouteCollection where D: QuerySupporting {
    typealias Database = D

    func boot(router: Router) throws {
        let usersRoute = router.grouped("api", "users")
        usersRoute.get(use: getAllHandler)
        usersRoute.get(User<Database>.parameter, use: getHandler)

        let basicAuthMiddleware = User<Database>.basicAuthMiddleware(using: BCryptDigest())
        let basicAuthGroup = usersRoute.grouped(basicAuthMiddleware)
        basicAuthGroup.post("login", use: loginHandler)
    }

    func getAllHandler(_ req: Request) throws -> Future<[User<Database>]> {
        return User.query(on: req).all()
    }

    func getHandler(_ req: Request) throws -> Future<User<Database>> {
        return try req.parameters.next(User<Database>.self)
    }

    func loginHandler(_ req: Request) throws -> Future<User<Database>> {
        let user = try req.requireAuthenticated(User<Database>.self)
//        let token = try AccessToken<Database>.generate(for: user)
        user.failedLogins = 0
        user.lastLogin = Date()
        return user.save(on: req)
    }
}

