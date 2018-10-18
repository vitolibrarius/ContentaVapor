import Vapor
import Leaf
import Authentication
import FluentSQLite
import ContentaTools
import ContentaUserModel

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Configure a SQLite database
    let dbDir: ToolDirectory = ToolDirectory.systemTmp.subdirectory("SampleSQL")
    if dbDir.exists == false {
        do {
            try dbDir.mkdir()
        }
        catch {
            print(error.localizedDescription)
            exit(1)
        }
    }
    let dbFile:ToolFile = dbDir.file("sample.sqlite")
    print(dbFile)
    let sqlite = try SQLiteDatabase(storage: .file(path: dbFile.absolutePath ))

    /// Register providers first
    try services.register(FluentSQLiteProvider())
    try services.register(AuthenticationProvider())

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router, database: sqlite)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    middlewares.use(SessionsMiddleware.self)
    services.register(middlewares)


    /// Register the configured SQLite database to the database config.
    var databases = DatabasesConfig()
    databases.add(database: sqlite, as: .sqlite)
    services.register(databases)

    /// Configure migrations
    var migrations = MigrationConfig()
    ContentUserModelMigrationManager<SQLiteDatabase>.configureMigrations(migrations: &migrations, forDatabase: .sqlite)
    services.register(migrations)

    // Configure the rest of your application here    
    config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)
}
