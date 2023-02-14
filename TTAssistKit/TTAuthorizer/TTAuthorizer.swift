//
//  TTAuthorizer.swift
//  ActiveLabel
//
//  Created by 　hong on 2022/12/13.
//

import Foundation
import UIKit
import RxSwift
import AssetsLibrary
import CoreLocation
import CoreTelephony
import MediaPlayer
import Photos

open class TTAuthorizer: NSObject {
    public static let shared = TTAuthorizer()
}

public extension TTAuthorizer {
    /// MARK: - 检测是有摄像头权限
    func checkCameraAuthorization() -> Observable<Bool> {
        return Single<Bool>.create {(single) -> Disposable in
            let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            
            switch authStatus {
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: AVMediaType.video) {isGranted in
                    single(.success(isGranted))
                }
            case .authorized:
                single(.success(true))
            case .restricted,.denied:
                single(.success(false))
            default:
                single(.success(false))
                break
            }
            return Disposables.create {}
        }.observe(on: MainScheduler.instance).asObservable()
    }
    
    
    // MARK: - 检测是否有麦克风权限
    func checkMicrophoneAuthorization() -> Observable<Bool> {
        return Single<Bool>.create {(single) -> Disposable in
            let authStatus = AVAudioSession.sharedInstance().recordPermission
            switch authStatus {
            case .undetermined:
                AVAudioSession.sharedInstance().requestRecordPermission {isGranted in
                    single(.success(isGranted))
                }
            case .granted:
                single(.success(true))
            case .denied:
                single(.success(false))
            default:
                single(.success(false))
                break
            }
            return Disposables.create {}
        }.observe(on: MainScheduler.instance).asObservable()
    }
    
    
    // MARK: - 检测是否有相册权限
    func checkPhotoLibraryAuthorization() -> Observable<(Bool,PHAuthorizationStatus)> {
        return Single<(Bool,PHAuthorizationStatus)>.create {(single) -> Disposable in
            func checkDetailStatus() {
                if #available(iOS 14, *) {
                    let isAuthorized = authStatus == .limited || authStatus == .authorized
                    single(.success((isAuthorized,authStatus)))
                } else {
                    single(.success((authStatus == .authorized,authStatus)))
                }
            }
            
            let authStatus = PHPhotoLibrary.authorizationStatus()
            if authStatus == .notDetermined {
                PHPhotoLibrary.requestAuthorization {firstAuthStatus in
                    checkDetailStatus()
                }
            }else {
                checkDetailStatus()
            }
            return Disposables.create {}
        }.observe(on: MainScheduler.instance).asObservable()
    }
    
    
    // MARK: - 检测是否有定位权限
    func checkLocationAuthorization() -> Observable<(Bool,CLAuthorizationStatus)> {
        return Single<(Bool,CLAuthorizationStatus)>.create {(single) -> Disposable in
            let authStatus = CLLocationManager.authorizationStatus()
            var timerDisposeble: Disposable?
            switch authStatus {
            case .notDetermined:
                let tempManager = CLLocationManager()
                tempManager.requestWhenInUseAuthorization()
                
                timerDisposeble =   Observable<Int>.interval(RxTimeInterval.milliseconds(1000), scheduler: MainScheduler.instance).subscribe(onNext: {(_) in
                    let checkingStatus = CLLocationManager.authorizationStatus()
                    if checkingStatus != .notDetermined {
                        let isAuthorized = checkingStatus == .authorizedAlways || checkingStatus == .authorizedWhenInUse
                        single(.success((isAuthorized,checkingStatus)))
                    }
                })
            case .authorizedWhenInUse,.authorizedAlways:
                single(.success((true,authStatus)))
            case .restricted,.denied:
                single(.success((false,authStatus)))
            default:
                single(.success((false,authStatus)))
                break
            }
            
            if timerDisposeble != nil {
                return timerDisposeble!
            }else {
                return Disposables.create()
            }
        }.observe(on: MainScheduler.instance).asObservable()
    }
}

//
//import CoreLocation
//
//class ViewController: UIViewController, CLLocationManagerDelegate {
//
//    let locationManager = CLLocationManager()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // 设置CLLocationManager的代理
//        locationManager.delegate = self
//
//        // 如果用户没有授权访问位置，则请求授权
//        if CLLocationManager.authorizationStatus() == .notDetermined {
//            locationManager.requestWhenInUseAuthorization()
//        }
//    }
//
//    // CLLocationManagerDelegate方法，处理位置授权状态的更改
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        switch status {
//        case .authorizedWhenInUse:
//            // 当用户授权使用应用程序时，开始更新位置信息
//            locationManager.startUpdatingLocation()
//        default:
//            // 其他情况
//            break
//        }
//    }
//
//    // 在需要时停止位置更新
//    func stopUpdatingLocation() {
//        locationManager.stopUpdatingLocation()
//    }
//
//}
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//public extension TTAuthorizer {
//
//
//    // MARK: - 跳转系统设置界面
//    func openSettingUrl(_ type: TTPermissionsType? = nil, alert: Bool = true) {
//        let title = "访问受限"
//        var message = "请点击“前往”，允许访问权限"
//        let appName: String =
//        (Bundle.main.infoDictionary!["CFBundleDisplayName"] ?? "") as! String  //App 名称
//        if type == .camera {  // 相机
//            message = "请在iPhone的\"设置-隐私-相机\"选项中，允许\"\(appName)\"访问你的相机"
//        } else if type == .photo {  // 相册
//            message = "请在iPhone的\"设置-隐私-照片\"选项中，允许\"\(appName)\"访问您的相册"
//        } else if type == .location {  // 位置
//            message = "请在iPhone的\"设置-隐私-定位服务\"选项中，允许\"\(appName)\"访问您的位置，获得更多商品信息"
//        } else if type == .network {  // 网络
//            message = "请在iPhone的\"设置-蜂窝移动网络\"选项中，允许\"\(appName)\"访问您的移动网络"
//        } else if type == .microphone {  // 麦克风
//            message = "请在iPhone的\"设置-隐私-麦克风\"选项中，允许\"\(appName)\"访问您的麦克风"
//        } else if type == .media {  // 媒体库
//            message = "请在iPhone的\"设置-隐私-媒体与Apple Music\"选项中，允许\"\(appName)\"访问您的媒体库"
//        }
//        let url = URL(string: UIApplication.openSettingsURLString)
//
//        if alert {
//            let alertController = UIAlertController(
//                title: title,
//                message: message,
//                preferredStyle: .alert)
//            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
//            let settingsAction = UIAlertAction(
//                title: "前往", style: .default,
//                handler: {
//                    (action) -> Void in
//                    if UIApplication.shared.canOpenURL(url!) {
//                        if #available(iOS 10, *) {
//                            UIApplication.shared.open(
//                                url!, options: [:], completionHandler: { (success) in })
//                        } else {
//                            UIApplication.shared.openURL(url!)
//                        }
//                    }
//                })
//            alertController.addAction(cancelAction)
//            alertController.addAction(settingsAction)
//            UIApplication.shared.keyWindow?.rootViewController?.present(
//                alertController, animated: true, completion: nil)
//        } else {
//            if UIApplication.shared.canOpenURL(url!) {
//                if #available(iOS 10, *) {
//                    UIApplication.shared.open(
//                        url!, options: [:], completionHandler: { (success) in })
//                } else {
//                    UIApplication.shared.openURL(url!)
//                }
//            }
//        }
//    }
//
//
//}
