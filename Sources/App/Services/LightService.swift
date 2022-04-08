import Foundation
import Vapor

protocol LightServiceProtocol: AnyObject {
    func manualSwitch(_ isOn: Bool)
    func activateTimer(_ timerModel: LightTimerModel)
    func deactivateTimer()
    func checkState() -> Bool
}

class LightService: LightServiceProtocol {
    
    private var timerActivated = false
    private var turnedOn = false
    private var timer: DispatchSourceTimer!
    
    func manualSwitch(_ isOn: Bool) {
        deactivateTimer()
        switchLight(isOn)
    }
    
    func activateTimer(_ timerModel: LightTimerModel) {
        deactivateTimer()
        guard let startTimeTupple = createTimeTuple(for: timerModel.startTime),
              let endTimeTupple = createTimeTuple(for: timerModel.endTime) else {
                  timerActivated = false
                  return
              }
        startTimer(for: startTimeTupple, endTimeTupple)
    }
    
    func deactivateTimer() {
        timerActivated = false
        timer = nil
    }
    
    func checkState() -> Bool {
        return turnedOn
    }
}

private extension LightService {
    
    func switchLight(_ isOn: Bool) {
        turnedOn = isOn
        print(isOn ? "Light turn on" : "Light turn off")
    }
    
    func createTimeTuple(for stringTime: String) -> (UInt16, UInt16)? {
        let stringDigits = stringTime.components(separatedBy: ":")
        let hours = UInt16(stringDigits.first ?? "")
        let minutes = UInt16(stringDigits.last ?? "")
        
        guard let hours = hours, hours >= 0 && hours <= 23,
              let minutes = minutes, minutes >= 0 && minutes <= 59 else {
                  return nil
              }
        return (hours, minutes)
    }
    
    func startTimer(for startTime: (UInt16, UInt16), _ endTime: (UInt16, UInt16)) {
        timerActivated = true
        
        timer = DispatchSource.makeTimerSource()
        timer.schedule(deadline: .now(), repeating: 2.0)
        timer.setEventHandler { [weak self] in
            guard let currentTime = self?.currentTime() else { return }
            
            if  currentTime.0 >= startTime.0 &&
                currentTime.1 >= startTime.1 &&
                currentTime.0 <= endTime.0 &&
                currentTime.1 < endTime.1 &&
                !(self?.turnedOn ?? false) {
                    self?.switchLight(true)
            } else if (self?.turnedOn ?? false) && currentTime.0 >= endTime.0 && currentTime.1 >= endTime.1 {
                self?.switchLight(false)
            }
        }
        timer.resume()
    }
    
    func currentTime() -> (UInt16, UInt16) {
        let date = Date()
        let calendar = Calendar.current
        let hours = UInt16(calendar.component(.hour, from: date))
        let minutes = UInt16(calendar.component(.minute, from: date))
        return (hours, minutes)
    }
}
