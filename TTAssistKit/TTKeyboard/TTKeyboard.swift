//
//  TTNetObserver.swift
//  ActiveLabel
//
//  Created by 　hong on 2023/1/6.
//

import Foundation
import RxSwift
import RxCocoa
import RxRelay
import RxOptional
import NSObject_Rx

open class TTKeyboard: NSObject {
    public static let shared = TTKeyboard()

    //  键盘是否正在显示
    public let isKeyboardShowing = BehaviorRelay<Bool>.init(value: false)

    // 变更空视图的高度
    var keyboardAnimateInteval: CGFloat = 0.25

    // 收到键盘高度的时候，变更其他面板的约束
   private var keyboardHeight: CGFloat = 0

    // 键盘高度变更
    public let keyboardChangingHeight = BehaviorRelay<CGFloat>.init(value: 0.0)

    override init() {
        super.init()
        NotificationCenter.default.rx.notification(
            UIApplication.keyboardWillChangeFrameNotification
        ).distinctUntilChanged().subscribe(onNext: {
            [weak self] notification in
            guard let self = self else { return }
            // 显示键盘
            if let endBounce = notification.userInfo?["UIKeyboardFrameEndUserInfoKey"] as? CGRect,
                endBounce.height > 100,
                let beginBounce = notification.userInfo?["UIKeyboardFrameBeginUserInfoKey"]
                    as? CGRect
            {

                // 真正高，
                let realHeight = self.fetchRealKeyboardHeight()
                if realHeight != self.keyboardHeight {
                    self.keyboardHeight = realHeight
                }

                
                let screenWidth = UIScreen.main.bounds.width
                let screenHeight = UIScreen.main.bounds.height
                
                // 收起键盘
                if endBounce.origin.y != screenWidth && endBounce.origin.y != screenHeight {
                    self.isKeyboardShowing.accept(true)
                    self.keyboardChangingHeight.accept(
                        realHeight < endBounce.height ? realHeight : endBounce.height)
                } else {
                    self.isKeyboardShowing.accept(false)

                    self.keyboardChangingHeight.accept(0)
                }
                //   debugPrint("键盘的end\(endBounce)  begin\(beginBounce)")
            }

        }).disposed(by: rx.disposeBag)
    }

   private func fetchRealKeyboardHeight() -> CGFloat {
        let keyboardWindow = UIApplication.shared.keyWindow
        let inputView = keyboardWindow?.rootViewController?.view.tkp_findSubview(
            "UIInputSetHostView",resursion: true)
        if let inputView = inputView {
            return inputView.bounds.height
        }
        return 0
    }
}


public extension TTKeyboard {
    func dismissKeyboard() {
        UIApplication.shared.keyWindow?.endEditing(true)
    }
}


fileprivate extension UIView {
    func tkp_findSubview(_ name: String?) -> UIView? {
        return tkp_findSubview(name, resursion: false)
    }

    func tkp_findSubview(_ name: String?, resursion: Bool) -> UIView? {
        if let tempClass: AnyClass = NSClassFromString(name ?? "") {
            for subview in subviews {
                subview.isKind(of: tempClass)
                return subview
            }
        }

        if resursion {
            for subview in subviews {
                let tempView = subview.tkp_findSubview(name, resursion: resursion)
                if let tempView = tempView {
                    return tempView
                }
            }
        }

        return nil
    }
}
