//
//  TTNetObserver.swift
//  ActiveLabel
//
//  Created by 　hong on 2023/1/6.
//

import Foundation
import Reachability
import RxSwift
import RxCocoa
import RxRelay
import RxOptional
import NSObject_Rx

open class TTNetObserver: NSObject {
    public enum State {
        case none,unavailable, wifi, cellular
    }
    // 对外单利
    public static let shared = TTNetObserver()
    
    // 私有监控主体
    private let reachability = try! Reachability()
    
    public var hasNet: Bool {
        switch netStateChangeDetail.value {
        case .cellular:
            return true
        case .wifi:
            return true
        case .unavailable:
            return false
        case .none:
            return false
        }
    }
    
    // 网络变更
    public let netStateChangeDetail = BehaviorRelay<TTNetObserver.State>.init(value: .none)
    
    // 是否有网
    public let netStateChange = PublishSubject<Bool>()
    
    override init() {
        super.init()
        try? reachability.startNotifier()
        setupEvent()
    }
    
    func setupEvent() {
        reachability.whenReachable = { [weak self] reach in guard let self = self else { return }
            var state = TTNetObserver.State.none
            switch reach.connection {
            case .none:
                state = .none
            case .unavailable:
                state = .unavailable
            case .cellular:
                state = .cellular
            case .wifi:
                state = .wifi
            }
            
            
            self.netStateChangeDetail.accept(state)
            self.netStateChange.onNext(self.hasNet)
        }
        
        // 没有网络下的推送
        reachability.whenUnreachable = { [weak self] _ in guard let self = self else { return }
//            print("Not reachable")
            self.netStateChangeDetail.accept(.unavailable)
            self.netStateChange.onNext(self.hasNet)
        }
    }
    
    func stopObserver() {
        reachability.stopNotifier()
    }
}
