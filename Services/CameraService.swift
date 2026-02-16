import AVFoundation
import UIKit

enum CameraPermissionStatus {
    case authorized
    case denied
    case notDetermined
    case restricted
}

@MainActor
final class CameraService {
    static let shared = CameraService()

    private init() {}

    var permissionStatus: CameraPermissionStatus {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return .authorized
        case .denied:
            return .denied
        case .notDetermined:
            return .notDetermined
        case .restricted:
            return .restricted
        @unknown default:
            return .denied
        }
    }

    var isCameraAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    func requestPermission() async -> CameraPermissionStatus {
        await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .video) { granted in
                continuation.resume(returning: granted ? .authorized : .denied)
            }
        }
    }
}
