import Vapor
import Routing
import Fluent
import ContentaUserModel

/// Register your application's routes here.
public func routes<D: QuerySupporting>(_ router: Router, database: D) throws {

    typealias Database = D
    
    router.get("hello") { req in
        return "Hello, world!"
    }

    router.get("users") { req -> Future<View> in
        return User<Database>.query(on: req).all().flatMap { users in
            let data = ["userlist": users]
            return try req.view().render("userview", data)
        }
    }

    let usersController = UserController<Database>()
    try router.register(collection: usersController)

    let websiteController = WebsiteController()
    try router.register(collection: websiteController)

    // Example of configuring a controller
//    let userController = UserController()
//    router.get("users", use: userController.index)
//    router.post("users", use: userController.create)
//    router.delete("users", User.parameter, use: userController.delete)
    
//    let t = GenericController<User>()
//    router.get("xyz", use: t.index)
}
