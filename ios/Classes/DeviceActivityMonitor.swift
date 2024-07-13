import ScreenTime

class DeviceActivityMonitor: DeviceActivityMonitor {
  func processDailyUsageData() {
    do {
      let mostUsed = try device.request(.mostUsedApplications(period: .day))
      
      var jsonArray = JSON.array()
      for app in mostUsed.applications {
        let appName = app.displayName
        let iconData = try app.request(.icon.pngData)
        let usageDuration = app.usageDuration
        let appData = JSON([
          "name": appName,
          "usage": usageDuration,
          "icon": iconData.base64EncodedString()
        ])
        jsonArray.append(appData)
      }
      
      
    } catch let error {
      print("Error retrieving app usage data: \(error)")
    }
  }
  
  override func intervalDidEnd(for activity: DeviceActivityName) {
    super.intervalDidEnd(for: activity)
    if activity == .day {
      processDailyUsageData()
    }
  }
}
