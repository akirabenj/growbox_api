import Vapor

struct LightController: RouteCollection {
    
    private let service: LightServiceProtocol
    
    init(service: LightServiceProtocol) {
        self.service = service
    }
    
    func boot(routes: RoutesBuilder) throws {
        let lightRoutes = routes.grouped("light")
        lightRoutes.post("manual_switch", use: manualSwitch)
        lightRoutes.post("activate_timer", use: activateTimer)
        lightRoutes.get("deactivate_timer", use: deactivateTimer)
        lightRoutes.get("check", use: checkSwitch)
    }
    
    func manualSwitch(_ req: Request) throws -> String {
        guard let isOn = try? req.content.decode(Bool.self) else {
            throw Abort(.badRequest)
        }
        service.manualSwitch(isOn)
        return "success"
    }
    
    func activateTimer(_ req: Request) throws -> String {
        guard let timerModel = try? req.content.decode(LightTimerModel.self) else {
            throw Abort(.badRequest)
        }
        service.activateTimer(timerModel)
        return "success"
    }
    
    func deactivateTimer(_ req: Request) -> String {
        service.deactivateTimer()
        return "success"
    }
    
    func checkSwitch(_ req: Request) -> UInt8 {
        return service.checkState() ? 1 : 0
    }
}
