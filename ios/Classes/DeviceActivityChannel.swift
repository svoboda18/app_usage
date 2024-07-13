import DeviceActivityMonitor

class DeviceActivityChannel: FlutterModule {
  private let channel = MethodChannel("device_activity")
  
  override func configure(withParameters parameters: [String: Any]) -> FlutterEngine {
    let flutterEngine = super.configure(withParameters: parameters)
    channel.setMethodCallHandler { [weak self] (call, result) in
      switch call.method {
      case "startMonitoring":
        self?.startMonitoring(result: result)
      case "getDailyUsageData":
        self?.getDailyUsageData(result: result)
      default:
        result(FlutterError(code: "unsupported_method", message: "Unsupported method", details: nil))
      }
    }
    return flutterEngine
  }
  
  private func startMonitoring(result: @escaping FlutterResult) {
    device.request(.dailyActivity) { success in
      result(success ? ["message": "Monitoring started"] : ["error": "Monitoring failed"])
    }
  }
  
  private func getDailyUsageData(result: @escaping FlutterResult) {
    processDailyUsageData { data in
      if let data = data {
        result(data.rawString())
      } else {
        result(FlutterError(code: "error", message: "Failed to retrieve data", details: nil))
      }
    }
  }
}