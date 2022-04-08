import Vapor

func routes(_ app: Application) throws {
    let service = LightService()
    try app.register(collection: LightController(service: service))
}
