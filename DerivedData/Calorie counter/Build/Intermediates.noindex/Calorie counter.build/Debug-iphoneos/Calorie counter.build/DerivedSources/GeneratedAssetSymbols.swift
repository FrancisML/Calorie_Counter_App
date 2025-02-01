import Foundation
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ColorResource {

}

// MARK: - Image Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ImageResource {

    /// The "AL-0" asset catalog image resource.
    static let AL_0 = DeveloperToolsSupport.ImageResource(name: "AL-0", bundle: resourceBundle)

    /// The "AL-1" asset catalog image resource.
    static let AL_1 = DeveloperToolsSupport.ImageResource(name: "AL-1", bundle: resourceBundle)

    /// The "AL-2" asset catalog image resource.
    static let AL_2 = DeveloperToolsSupport.ImageResource(name: "AL-2", bundle: resourceBundle)

    /// The "AL-3" asset catalog image resource.
    static let AL_3 = DeveloperToolsSupport.ImageResource(name: "AL-3", bundle: resourceBundle)

    /// The "AL-4" asset catalog image resource.
    static let AL_4 = DeveloperToolsSupport.ImageResource(name: "AL-4", bundle: resourceBundle)

    /// The "AL-5" asset catalog image resource.
    static let AL_5 = DeveloperToolsSupport.ImageResource(name: "AL-5", bundle: resourceBundle)

    /// The "AL-6" asset catalog image resource.
    static let AL_6 = DeveloperToolsSupport.ImageResource(name: "AL-6", bundle: resourceBundle)

    /// The "BMR" asset catalog image resource.
    static let BMR = DeveloperToolsSupport.ImageResource(name: "BMR", bundle: resourceBundle)

    /// The "Empty man PP" asset catalog image resource.
    static let emptyManPP = DeveloperToolsSupport.ImageResource(name: "Empty man PP", bundle: resourceBundle)

    /// The "Empty woman PP" asset catalog image resource.
    static let emptyWomanPP = DeveloperToolsSupport.ImageResource(name: "Empty woman PP", bundle: resourceBundle)

    /// The "SliderIcon" asset catalog image resource.
    static let sliderIcon = DeveloperToolsSupport.ImageResource(name: "SliderIcon", bundle: resourceBundle)

    /// The "age" asset catalog image resource.
    static let age = DeveloperToolsSupport.ImageResource(name: "age", bundle: resourceBundle)

    /// The "bike" asset catalog image resource.
    static let bike = DeveloperToolsSupport.ImageResource(name: "bike", bundle: resourceBundle)

    /// The "bolt" asset catalog image resource.
    static let bolt = DeveloperToolsSupport.ImageResource(name: "bolt", bundle: resourceBundle)

    /// The "calender" asset catalog image resource.
    static let calender = DeveloperToolsSupport.ImageResource(name: "calender", bundle: resourceBundle)

    /// The "calx" asset catalog image resource.
    static let calx = DeveloperToolsSupport.ImageResource(name: "calx", bundle: resourceBundle)

    /// The "carrot" asset catalog image resource.
    static let carrot = DeveloperToolsSupport.ImageResource(name: "carrot", bundle: resourceBundle)

    /// The "flame" asset catalog image resource.
    static let flame = DeveloperToolsSupport.ImageResource(name: "flame", bundle: resourceBundle)

    /// The "hungry" asset catalog image resource.
    static let hungry = DeveloperToolsSupport.ImageResource(name: "hungry", bundle: resourceBundle)

    /// The "logo" asset catalog image resource.
    static let logo = DeveloperToolsSupport.ImageResource(name: "logo", bundle: resourceBundle)

    /// The "manorwoman" asset catalog image resource.
    static let manorwoman = DeveloperToolsSupport.ImageResource(name: "manorwoman", bundle: resourceBundle)

    /// The "scale" asset catalog image resource.
    static let scale = DeveloperToolsSupport.ImageResource(name: "scale", bundle: resourceBundle)

    /// The "scaleIndicator" asset catalog image resource.
    static let scaleIndicator = DeveloperToolsSupport.ImageResource(name: "scaleIndicator", bundle: resourceBundle)

    /// The "stats" asset catalog image resource.
    static let stats = DeveloperToolsSupport.ImageResource(name: "stats", bundle: resourceBundle)

    /// The "tape" asset catalog image resource.
    static let tape = DeveloperToolsSupport.ImageResource(name: "tape", bundle: resourceBundle)

    /// The "target" asset catalog image resource.
    static let target = DeveloperToolsSupport.ImageResource(name: "target", bundle: resourceBundle)

    /// The "trophy" asset catalog image resource.
    static let trophy = DeveloperToolsSupport.ImageResource(name: "trophy", bundle: resourceBundle)

}

// MARK: - Color Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

}
#endif

// MARK: - Image Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    /// The "AL-0" asset catalog image.
    static var AL_0: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .AL_0)
#else
        .init()
#endif
    }

    /// The "AL-1" asset catalog image.
    static var AL_1: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .AL_1)
#else
        .init()
#endif
    }

    /// The "AL-2" asset catalog image.
    static var AL_2: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .AL_2)
#else
        .init()
#endif
    }

    /// The "AL-3" asset catalog image.
    static var AL_3: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .AL_3)
#else
        .init()
#endif
    }

    /// The "AL-4" asset catalog image.
    static var AL_4: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .AL_4)
#else
        .init()
#endif
    }

    /// The "AL-5" asset catalog image.
    static var AL_5: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .AL_5)
#else
        .init()
#endif
    }

    /// The "AL-6" asset catalog image.
    static var AL_6: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .AL_6)
#else
        .init()
#endif
    }

    /// The "BMR" asset catalog image.
    static var BMR: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .BMR)
#else
        .init()
#endif
    }

    /// The "Empty man PP" asset catalog image.
    static var emptyManPP: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .emptyManPP)
#else
        .init()
#endif
    }

    /// The "Empty woman PP" asset catalog image.
    static var emptyWomanPP: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .emptyWomanPP)
#else
        .init()
#endif
    }

    /// The "SliderIcon" asset catalog image.
    static var sliderIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .sliderIcon)
#else
        .init()
#endif
    }

    /// The "age" asset catalog image.
    static var age: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .age)
#else
        .init()
#endif
    }

    /// The "bike" asset catalog image.
    static var bike: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .bike)
#else
        .init()
#endif
    }

    /// The "bolt" asset catalog image.
    static var bolt: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .bolt)
#else
        .init()
#endif
    }

    /// The "calender" asset catalog image.
    static var calender: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .calender)
#else
        .init()
#endif
    }

    /// The "calx" asset catalog image.
    static var calx: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .calx)
#else
        .init()
#endif
    }

    /// The "carrot" asset catalog image.
    static var carrot: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .carrot)
#else
        .init()
#endif
    }

    /// The "flame" asset catalog image.
    static var flame: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .flame)
#else
        .init()
#endif
    }

    /// The "hungry" asset catalog image.
    static var hungry: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .hungry)
#else
        .init()
#endif
    }

    /// The "logo" asset catalog image.
    static var logo: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .logo)
#else
        .init()
#endif
    }

    /// The "manorwoman" asset catalog image.
    static var manorwoman: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .manorwoman)
#else
        .init()
#endif
    }

    /// The "scale" asset catalog image.
    static var scale: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .scale)
#else
        .init()
#endif
    }

    /// The "scaleIndicator" asset catalog image.
    static var scaleIndicator: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .scaleIndicator)
#else
        .init()
#endif
    }

    /// The "stats" asset catalog image.
    static var stats: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .stats)
#else
        .init()
#endif
    }

    /// The "tape" asset catalog image.
    static var tape: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tape)
#else
        .init()
#endif
    }

    /// The "target" asset catalog image.
    static var target: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .target)
#else
        .init()
#endif
    }

    /// The "trophy" asset catalog image.
    static var trophy: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .trophy)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    /// The "AL-0" asset catalog image.
    static var AL_0: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .AL_0)
#else
        .init()
#endif
    }

    /// The "AL-1" asset catalog image.
    static var AL_1: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .AL_1)
#else
        .init()
#endif
    }

    /// The "AL-2" asset catalog image.
    static var AL_2: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .AL_2)
#else
        .init()
#endif
    }

    /// The "AL-3" asset catalog image.
    static var AL_3: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .AL_3)
#else
        .init()
#endif
    }

    /// The "AL-4" asset catalog image.
    static var AL_4: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .AL_4)
#else
        .init()
#endif
    }

    /// The "AL-5" asset catalog image.
    static var AL_5: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .AL_5)
#else
        .init()
#endif
    }

    /// The "AL-6" asset catalog image.
    static var AL_6: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .AL_6)
#else
        .init()
#endif
    }

    /// The "BMR" asset catalog image.
    static var BMR: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .BMR)
#else
        .init()
#endif
    }

    /// The "Empty man PP" asset catalog image.
    static var emptyManPP: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .emptyManPP)
#else
        .init()
#endif
    }

    /// The "Empty woman PP" asset catalog image.
    static var emptyWomanPP: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .emptyWomanPP)
#else
        .init()
#endif
    }

    /// The "SliderIcon" asset catalog image.
    static var sliderIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .sliderIcon)
#else
        .init()
#endif
    }

    /// The "age" asset catalog image.
    static var age: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .age)
#else
        .init()
#endif
    }

    /// The "bike" asset catalog image.
    static var bike: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .bike)
#else
        .init()
#endif
    }

    /// The "bolt" asset catalog image.
    static var bolt: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .bolt)
#else
        .init()
#endif
    }

    /// The "calender" asset catalog image.
    static var calender: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .calender)
#else
        .init()
#endif
    }

    /// The "calx" asset catalog image.
    static var calx: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .calx)
#else
        .init()
#endif
    }

    /// The "carrot" asset catalog image.
    static var carrot: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .carrot)
#else
        .init()
#endif
    }

    /// The "flame" asset catalog image.
    static var flame: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .flame)
#else
        .init()
#endif
    }

    /// The "hungry" asset catalog image.
    static var hungry: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .hungry)
#else
        .init()
#endif
    }

    /// The "logo" asset catalog image.
    static var logo: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .logo)
#else
        .init()
#endif
    }

    /// The "manorwoman" asset catalog image.
    static var manorwoman: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .manorwoman)
#else
        .init()
#endif
    }

    /// The "scale" asset catalog image.
    static var scale: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .scale)
#else
        .init()
#endif
    }

    /// The "scaleIndicator" asset catalog image.
    static var scaleIndicator: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .scaleIndicator)
#else
        .init()
#endif
    }

    /// The "stats" asset catalog image.
    static var stats: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .stats)
#else
        .init()
#endif
    }

    /// The "tape" asset catalog image.
    static var tape: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tape)
#else
        .init()
#endif
    }

    /// The "target" asset catalog image.
    static var target: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .target)
#else
        .init()
#endif
    }

    /// The "trophy" asset catalog image.
    static var trophy: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .trophy)
#else
        .init()
#endif
    }

}
#endif

// MARK: - Thinnable Asset Support -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ColorResource {

    private init?(thinnableName: String, bundle: Bundle) {
#if canImport(AppKit) && os(macOS)
        if AppKit.NSColor(named: NSColor.Name(thinnableName), bundle: bundle) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIColor(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}
#endif

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ImageResource {

    private init?(thinnableName: String, bundle: Bundle) {
#if canImport(AppKit) && os(macOS)
        if bundle.image(forResource: NSImage.Name(thinnableName)) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIImage(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

