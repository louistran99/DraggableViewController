//
//  ModalPresentationConfiguration.swift
//  Multibrand
//
//  Created by Louis Tran on 3/13/20.
//  Copyright © 2020 ZillowGroup. All rights reserved.
//

import Foundation

/// The direcection of the pan gesture recognizer
enum DragDirection {
  case draggingUp
  case draggingDown
}
/// Configure the metrics for each position of type `Position` and the metrics threshold to transition from one position to another.  All metrics are normalized to the full height of the screen.
enum Position {
    case collapsed
    case partiallyExpanded
    case expanded
}
/// The configuration object for modal presentation
public struct ModalPresentationConfiguration {
    /// the `.partiallyExpanded` position, 0.33 means that when presented in this position, the presented view controller is at the bottom 1/3 of the presenting view controller
    var defaultHalfHeight: CGFloat = 0.33
    /// the `.expanded` position, 1.0 means the presented view controller completly overlaps the presenting view controller
    var defaultFullHeight: CGFloat = 0.80
    /// the `.collapsed` position
    var defaultEmptyHeight: CGFloat = 0.0
    var defaultThreshold: CGFloat = 0.05
    var dampingRatio: CGFloat = 0.75
    var velocity: CGFloat = 5
    var animationDuration: TimeInterval = 0.5
    var isAllowedToDrag: Bool {
        if position == .expanded && dragDirection == .draggingUp {
            return false
        }
        return true
    }
    var dragDirection: DragDirection = .draggingUp
    /// the current position of the presented view controller
    var position: Position = .partiallyExpanded
    /// maximum frame
    var maxFrame = CGRect(x: 0, y: 0, width: UIWindow.root.bounds.width, height: UIWindow.root.bounds.height + UIWindow.root.safeAreaInsets.bottom)
    /// if true then user can tap on the `dimmerView` to dismiss
    var isAllowedTapToDismiss: Bool = false
    /// default initializer
    public init () {
    }
    /// Configure the modal presentation with this object.  If initialization is unsuccessful, the initializer will throw an error
    /// - Parameters:
    ///   - expanded: a value between 0.0 and 1.0 representing the `.expanded` state where 1.0 is the full screen height
    ///   - partiallyExpanded: a value between 0.0 and 1.0 representing the `.partiallyExpanded` state where 1.0 is the full screen height, must be less than the `expanded` value
    ///   - collapsed: a value between 0.0 and 1.0 where 1.0 is the full screen height, must be less thatn `partiallyExpanded` value
    ///   - isAllowedToDismissOnTap: if true, then the presented view controller can be dismissed when the user taps on the dimmer view
    public init (expanded: CGFloat? = nil, partiallyExpanded: CGFloat? = nil, collapsed: CGFloat? = nil, isAllowedToDismissOnTap: Bool? = nil) throws {
        if let unwrappedIsAllowedToDismissOnTap = isAllowedToDismissOnTap {
            self.isAllowedTapToDismiss = unwrappedIsAllowedToDismissOnTap
        }
        if let unwrappedExpanded = expanded {
            guard unwrappedExpanded < 1.0 else {
                throw ConfigurationError.unNormalizedValue("Expanded state should be between 0 and 1")
            }
            self.defaultFullHeight = unwrappedExpanded
        }
        if let unwrappedPartiallyExpanded = partiallyExpanded {
            guard unwrappedPartiallyExpanded < 1.0 else {
                throw ConfigurationError.unNormalizedValue("Partially expanded state must be between 0 and 1")
            }
            self.defaultHalfHeight = unwrappedPartiallyExpanded
        }
        if let unwrappedCollapsed = collapsed {
            guard unwrappedCollapsed < 1.0 else {
                throw ConfigurationError.unNormalizedValue("Collapsed state must be between 0 and 1")
            }
            self.defaultEmptyHeight = unwrappedCollapsed
        }
        guard self.defaultFullHeight > self.defaultHalfHeight, self.defaultHalfHeight > self.defaultEmptyHeight else {
            throw ConfigurationError.positionOrderError("For the view controller to be draggable to different states, this condition has to be met: expanded > partiallyExpanded > collapsed.  This condition is not met.")
        }
    }
    var normalizedHeight: CGFloat {
        switch position {
        case .collapsed:
            return defaultEmptyHeight
        case .expanded:
            return defaultFullHeight
        case .partiallyExpanded:
            return defaultHalfHeight
        }
    }
    var normalizedUpThreshold: CGFloat {
        switch position {
        case .collapsed, .partiallyExpanded:
            return 0
        case .expanded:
            /// when dragging up, the normalized distance from the bottom has to be greater than this threshold (default is 0.33 + 0.10 = 0.43) to position the presented view controller to the `.expanded` state
            return defaultThreshold + defaultHalfHeight
        }
    }
    var normalizeDownThreshold: CGFloat {
        switch position {
        case .collapsed:
            return 0
        case .partiallyExpanded:
            /// when dragging down the normalized distance from the bottom must be less this threshold (default is 0.33 - 0.1 = 0.23) to position the presented view controller to the `.collapsed` state
            return defaultHalfHeight - defaultThreshold
        case .expanded:
            /// when dragging down the normalized distance from the bottom must be less this threshold (default is 0.8 - 0.1 = 0.7) to position the presented view controller to the `.partiallyExpanded` or `.collapsed` state
            return defaultFullHeight - defaultThreshold
        }
    }
    var dimAlpha: CGFloat {
        switch position {
        case .collapsed:
            return 0
        case .expanded:
            return 0.5
        case .partiallyExpanded:
            return 0.5
        }
    }
    /// returns the y origin based of the `position` and screen height, from which we add the vertical drag offset, which in turn is the y offset of the presented view controller
    func calculateOriginYFromScreenHeight() -> CGFloat {
        return maxFrame.height * (1 - normalizedHeight)
    }
    /// returns the next position to animate to
    /// - Parameter dragOffset: the vertical drag offset in the presented view
    func nextPosition (_ dragOffset: CGFloat) -> Position {
        guard maxFrame.height != 0 else {
            return .collapsed
        }
        let normalizedDistanceFromBottom = 1.0 - dragOffset / maxFrame.height
        switch position {
        case .partiallyExpanded:
            if dragDirection == .draggingUp {
                if normalizedDistanceFromBottom > (defaultHalfHeight + defaultThreshold) {
                    return .expanded
                }
            } else {
                if normalizedDistanceFromBottom < (defaultHalfHeight - defaultThreshold) {
                    return .collapsed
                }
            }
        case .expanded:
            if dragDirection == .draggingDown {
                if normalizedDistanceFromBottom < (defaultFullHeight - defaultThreshold) {
                    return .collapsed
                }
            }
        default:
            break
        }
        return position
    }
    func springEffect (_ dampingRatio: CGFloat? = nil, _ initialVelocity: CGFloat? = nil) -> UISpringTimingParameters {
        guard let unwrappedDampingRatio = dampingRatio, let unwrappedInitialVelocity = initialVelocity else {
            return UISpringTimingParameters(dampingRatio: self.dampingRatio, initialVelocity: CGVector(dx: 0, dy: self.velocity))
        }

            return UISpringTimingParameters(dampingRatio: unwrappedDampingRatio, initialVelocity: CGVector(dx: 0, dy: unwrappedInitialVelocity))
    }
}
extension ModalPresentationConfiguration {
    enum ConfigurationError: Error, Equatable {
        case positionOrderError(String)
        case unNormalizedValue(String)
    }
}
