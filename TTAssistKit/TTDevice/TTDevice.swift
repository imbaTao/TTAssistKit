//
//  TTDevice.swift
//  ActiveLabel
//
//  Created by 　hong on 2022/12/13.
//

import Foundation
import UIKit
import RxRelay
import RxSwift
import RxCocoa
import NSObject_Rx

open class TTDevice: NSObject {
    public static let shared = TTDevice()

    // 方向旋转信号信号
    public let orientationRelay = BehaviorRelay<UIInterfaceOrientation>.init(value: .portrait)
    
    override init() {
        super.init()

        // 监听屏幕即将
//        NotificationCenter.default.rx.notification(
//            UIApplication.willChangeStatusBarOrientationNotification
//        ).subscribe(onNext: { [weak self] (_) in guard let self = self else { return }
//            let orientaion = UIApplication.shared.statusBarOrientation
//            self.orientationWillChangeRelay.accept(orientaion)
//        }).disposed(by: rx.disposeBag)

        
        //首次赋值
        orientationRelay.accept(UIApplication.shared.statusBarOrientation)
        
        let name = UIApplication.didChangeStatusBarOrientationNotification
    
        // 监听屏幕旋转完毕
        NotificationCenter.default.rx.notification(name).subscribe(onNext: { [weak self] (_) in guard let self = self else { return }
            let orientaion = UIApplication.shared.statusBarOrientation
            self.orientationRelay.accept(orientaion)
        }).disposed(by: rx.disposeBag)
    }
    
    
    // 强制横向旋转
    public func forceRotateDevice(_ orientation: UIInterfaceOrientation) {
        UIDevice.current.setValue(
            orientation.rawValue, forKey: "orientation")
    }
}


public extension TTDevice {
    // 当前的方向
    var orientation: UIInterfaceOrientation {
        return orientationRelay.value
    }

    var isPortrait: Bool {
        var isPortrait = false
        switch orientation {
        case .portrait, .portraitUpsideDown:
            isPortrait = true
        default:
            break
        }
        return isPortrait
    }
    
    var isLand: Bool {
        var isLand = false
        switch orientation {
        case .landscapeLeft, .landscapeRight:
            isLand = true
        default:
            break
        }
        return isLand
    }
}

