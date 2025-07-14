// swiftlint:disable all
// Generated using TuistAssets

import Foundation
import SwiftUI
#if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
import UIKit
#endif

// MARK: - Assets

public enum LeavnAsset {
    public enum Colors {
        public static let accentColor = ColorAsset(name: "AccentColor")
        public static let background = ColorAsset(name: "Background")
        public static let primaryText = ColorAsset(name: "PrimaryText")
        public static let secondaryText = ColorAsset(name: "SecondaryText")
        public static let success = ColorAsset(name: "Success")
        public static let warning = ColorAsset(name: "Warning")
        public static let error = ColorAsset(name: "Error")
        public static let cardBackground = ColorAsset(name: "CardBackground")
        public static let divider = ColorAsset(name: "Divider")
        public static let approvedGreen = ColorAsset(name: "ApprovedGreen")
        public static let pendingOrange = ColorAsset(name: "PendingOrange")
        public static let rejectedRed = ColorAsset(name: "RejectedRed")
    }
    
    public enum Images {
        public static let appIcon = ImageAsset(name: "AppIcon")
        public static let calendarIcon = ImageAsset(name: "CalendarIcon")
        public static let teamIcon = ImageAsset(name: "TeamIcon")
        public static let profileIcon = ImageAsset(name: "ProfileIcon")
        public static let notificationIcon = ImageAsset(name: "NotificationIcon")
        public static let leaveRequestIcon = ImageAsset(name: "LeaveRequestIcon")
        public static let checkmarkCircle = ImageAsset(name: "CheckmarkCircle")
        public static let xmarkCircle = ImageAsset(name: "XmarkCircle")
        public static let clockIcon = ImageAsset(name: "ClockIcon")
        public static let vacationIcon = ImageAsset(name: "VacationIcon")
        public static let sickLeaveIcon = ImageAsset(name: "SickLeaveIcon")
        public static let personalLeaveIcon = ImageAsset(name: "PersonalLeaveIcon")
    }
    
    public enum Symbols {
        public static let plus = "plus"
        public static let minus = "minus"
        public static let checkmark = "checkmark"
        public static let xmark = "xmark"
        public static let calendar = "calendar"
        public static let person = "person"
        public static let personFill = "person.fill"
        public static let bell = "bell"
        public static let bellFill = "bell.fill"
        public static let doc = "doc"
        public static let docFill = "doc.fill"
        public static let gear = "gear"
        public static let house = "house"
        public static let houseFill = "house.fill"
        public static let arrowRight = "arrow.right"
        public static let arrowLeft = "arrow.left"
        public static let chevronRight = "chevron.right"
        public static let chevronDown = "chevron.down"
        public static let ellipsis = "ellipsis"
        public static let magnifyingglass = "magnifyingglass"
    }
}

// MARK: - Implementation Details

public final class ColorAsset {
    public fileprivate(set) var name: String
    
    #if os(macOS)
    public typealias Color = NSColor
    #elseif os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
    public typealias Color = UIColor
    #endif
    
    @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, visionOS 1.0, *)
    public private(set) lazy var color: Color = {
        guard let color = Color(named: name, in: bundle, compatibleWith: nil) else {
            fatalError("Unable to load color asset named \\(name).")
        }
        return color
    }()
    
    #if canImport(SwiftUI)
    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, visionOS 1.0, *)
    public private(set) lazy var swiftUIColor: SwiftUI.Color = {
        SwiftUI.Color(name, bundle: bundle)
    }()
    #endif
    
    fileprivate init(name: String) {
        self.name = name
    }
}

public extension ColorAsset.Color {
    @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, visionOS 1.0, *)
    convenience init?(asset: ColorAsset) {
        self.init(named: asset.name, in: bundle, compatibleWith: nil)
    }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, visionOS 1.0, *)
public extension SwiftUI.Color {
    init(asset: ColorAsset) {
        self.init(asset.name, bundle: bundle)
    }
}
#endif

public struct ImageAsset {
    public fileprivate(set) var name: String
    
    #if os(macOS)
    public typealias Image = NSImage
    #elseif os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
    public typealias Image = UIImage
    #endif
    
    @available(iOS 8.0, tvOS 9.0, watchOS 2.0, macOS 10.7, visionOS 1.0, *)
    public var image: Image {
        let image = Image(named: name, in: bundle, compatibleWith: nil)
        guard let result = image else {
            fatalError("Unable to load image asset named \\(name).")
        }
        return result
    }
    
    #if canImport(SwiftUI)
    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, visionOS 1.0, *)
    public var swiftUIImage: SwiftUI.Image {
        SwiftUI.Image(name, bundle: bundle)
    }
    #endif
}

public extension ImageAsset.Image {
    @available(iOS 8.0, tvOS 9.0, watchOS 2.0, macOS 10.7, visionOS 1.0, *)
    convenience init?(asset: ImageAsset) {
        self.init(named: asset.name, in: bundle, compatibleWith: nil)
    }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, visionOS 1.0, *)
public extension SwiftUI.Image {
    init(asset: ImageAsset) {
        self.init(asset.name, bundle: bundle)
    }
}
#endif

// MARK: - Bundle Access

private let bundle = Bundle.module

// swiftlint:enable all