//
//  DraggableTransitionController.swift
//  Multibrand
//
//  Created by Louis Tran on 3/13/20.
//  Copyright © 2020 ZillowGroup. All rights reserved.
//

//import Foundation
import UIKit


class DraggableTransitionController: UIPresentationController {
    var modalConfiguration: ModalPresentationConfiguration = ModalPresentationConfiguration()
    weak var routingDelegate: Router?
    // MARK: UIPresentationController override
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        routingDelegate = presentedViewController as? Router
    }
    convenience init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, modalConfiguration: ModalPresentationConfiguration?) {
        self.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        if let unwrappedModalConfiguration = modalConfiguration {
            self.modalConfiguration = unwrappedModalConfiguration
        }
    }
    override var frameOfPresentedViewInContainerView: CGRect {
        let presentedOrigin = CGPoint(x: 0, y: modalConfiguration.calculateOriginYFromScreenHeight())
        let presentedSize = CGSize(width: modalConfiguration.maxFrame.size.width, height: modalConfiguration.maxFrame.size.height + 40)
        return CGRect(origin: presentedOrigin, size: presentedSize)
    }
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        super.dismissalTransitionDidEnd(completed)
        if completed {
            dimmingView.removeFromSuperview()
            presentedView?.removeGestureRecognizer(panOnPresented)
            routingDelegate?.didDismiss(self)
        }
    }
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        guard let containerView = containerView else {
            return
        }
        containerView.insertSubview(dimmingView, belowSubview: presentingViewController.view)
        dimmingView.alpha = modalConfiguration.dimAlpha
        dimmingView.backgroundColor = .black
        dimmingView.frame = containerView.frame
    }
    override func presentationTransitionDidEnd(_ completed: Bool) {
        animator = UIViewPropertyAnimator(duration: modalConfiguration.animationDuration, timingParameters: modalConfiguration.springEffect())
        animator?.isInterruptible = true
        panOnPresented = UIPanGestureRecognizer(target: self, action: #selector(userDidPan(panRecognizer:)))
        presentedView?.addGestureRecognizer(panOnPresented)
        if modalConfiguration.isAllowedTapToDismiss == true {
            dimmingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapToDismiss(_:))))
        }
    }
    // MARK: Handling user actions
    @objc private func handleTapToDismiss (_ tapGesture: UITapGestureRecognizer) {
        modalConfiguration.position = .collapsed
        animate(to: modalConfiguration.position)
    }
    @objc private func userDidPan(panRecognizer: UIPanGestureRecognizer) {
        let translationPoint = panRecognizer.translation(in: presentedView)
        let currentOriginY = modalConfiguration.calculateOriginYFromScreenHeight()
        let newOffset = currentOriginY + translationPoint.y
        modalConfiguration.dragDirection = translationPoint.y > 0 ? .draggingDown : .draggingUp
        if newOffset > 0 && modalConfiguration.isAllowedToDrag {
            switch panRecognizer.state {
            case .changed, .began:
                presentedView?.frame.origin.y = newOffset
            case .ended:
                animate(newOffset)
            default:
                break
            }
        }
    }
    private func animate(_ dragOffset: CGFloat) {
        let nextPosition = modalConfiguration.nextPosition(dragOffset)
        modalConfiguration.position = nextPosition
        animate(to: nextPosition)
    }
    private func animate(to position: Position) {
        guard let unwrappedAnimator = animator else {
            return
        }
        unwrappedAnimator.addAnimations {
            self.presentedView?.frame.origin.y = self.modalConfiguration.calculateOriginYFromScreenHeight()
            self.dimmingView.alpha = self.modalConfiguration.dimAlpha
        }
        unwrappedAnimator.addCompletion({ animationPosition in
            if animationPosition == .end {
                self.modalConfiguration.position = position
            }
            if position == .collapsed {
                self.presentedViewController.dismiss(animated: false, completion: nil)
            }
        })
        unwrappedAnimator.startAnimation()
    }
    // MARK: Private
    private var dimmingView = UIView()
    private var animator: UIViewPropertyAnimator?
    private var panOnPresented = UIGestureRecognizer()
}
