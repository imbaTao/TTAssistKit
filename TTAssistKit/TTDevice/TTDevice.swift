//
//  TTDevice.swift
//  ActiveLabel
//
//  Created by 　hong on 2022/12/13.
//

import Foundation
import UIKit

open class TTDevice: NSObject {
    public static let shared = TTDevice()

    let orientationRelay = BehaviorRelay<UIInterfaceOrientation>.init(value: .portrait)
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
        
        let name = NSNotification.Name.UIApplicationDidChangeStatusBarOrientation
    
        // 监听屏幕旋转完毕
        NotificationCenter.default.rx.notification(name).subscribe(onNext: { [weak self] (_) in guard let self = self else { return }
            let orientaion = UIApplication.shared.statusBarOrientation
            self.orientationRelay.accept(orientaion)
        }).disposed(by: rx.disposeBag)
    }
    
    
    // 强制横向旋转
    func forceRotateDevice(_ orientation: UIInterfaceOrientation) {
        UIDevice.current.setValue(
            orientation.rawValue, forKey: "orientation")
    }
}
