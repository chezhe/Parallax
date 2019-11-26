//
//  AppProtocols.swift
//  Parallax
//
//  Created by 王亮 on 2019/11/25.
//  Copyright © 2019 王亮. All rights reserved.
//

import Foundation

// MARK: - DiscloseView

protocol DiscloseView {
    func show()
    func hide()
}

// MARK: - EnableItem

protocol EnableItem {
    func enable()
    func disable()
}

// MARK: - StoreManagerDelegate

protocol StoreManagerDelegate: AnyObject {
    /// Provides the delegate with the App Store's response.
    func storeManagerDidReceiveResponse(_ response: [Section])

    /// Provides the delegate with the error encountered during the product request.
    func storeManagerDidReceiveMessage(_ message: String)
}

// MARK: - StoreObserverDelegate

protocol StoreObserverDelegate: AnyObject {
    /// Tells the delegate that the restore operation was successful.
    func storeObserverRestoreDidSucceed()

    /// Provides the delegate with messages.
    func storeObserverDidReceiveMessage(_ message: String)
}

// MARK: - SettingsDelegate

protocol SettingsDelegate: AnyObject {
    /// Tells the delegate that the user has requested the restoration of their purchases.
    func settingDidSelectRestore()
}
