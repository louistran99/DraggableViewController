//
//  Dismissable.swift
//  Multibrand
//
//  Created by Louis Tran on 10/8/19.
//  Copyright © 2019 ZillowGroup. All rights reserved.
//

import Foundation
public protocol Router: class {
    /// Called on the delegate, typically a view controller, when the view controller is dismissed so it can act on the user actions
    /// - Parameter sender: the caller
    func didDismiss(_ sender: Any)
    /// Called when the user selectes a sort criteria or dismisses
    ///
    /// This method is *optional*
    ///
    /// - parameter view: The InboxFilterViewModel
    func shouldDismiss( _ view: Any)
    /// Called when the user pops the  viewcontroller off the navigation stack
    ///
    /// This method is *optional*
    func shouldPop()
    /// Called to push a view concontroller
    ///
    /// This method is *optional*
    ///
    /// - parameter viewModel: the renter profile to show
    func shouldPush(_ renterProfile: Any)
    /// Called to present a view controller modally
    ///
    /// This method is *optional*
    func shouldPresent(_ renterHeaderViewModel: Any?)
}
extension Router {
    public func shouldDismiss( _ view: Any) {}
    public func shouldPop() {}
    public func shouldPush(_ renterProfile: Any) {}
    public func shouldPresent(_ renterHeaderViewModel: Any?) {}
    public func didDismiss(_ sender: Any) {}
}
