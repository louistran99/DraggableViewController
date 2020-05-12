//
//  DraggableTransitionAnimator.swift
//  Multibrand
//
//  Created by Louis Tran on 3/13/20.
//  Copyright © 2020 ZillowGroup. All rights reserved.
//

import UIKit

public class DraggableTransitionAnimator: NSObject {
    private var configurationObject: ModalPresentationConfiguration
    public init (configuration: ModalPresentationConfiguration) {
        self.configurationObject = configuration
    }
}
extension DraggableTransitionAnimator: UIViewControllerTransitioningDelegate {
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return DraggableTransitionController(presentedViewController: presented, presenting: presenting, modalConfiguration: configurationObject)
    }
}
