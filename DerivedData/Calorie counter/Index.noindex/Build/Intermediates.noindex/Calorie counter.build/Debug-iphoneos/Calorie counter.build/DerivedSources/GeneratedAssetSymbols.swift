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

    /// The "ABS" asset catalog image resource.
    static let ABS = DeveloperToolsSupport.ImageResource(name: "ABS", bundle: resourceBundle)

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

    /// The "AddCustom" asset catalog image resource.
    static let addCustom = DeveloperToolsSupport.ImageResource(name: "AddCustom", bundle: resourceBundle)

    /// The "AddFood" asset catalog image resource.
    static let addFood = DeveloperToolsSupport.ImageResource(name: "AddFood", bundle: resourceBundle)

    /// The "AddWater" asset catalog image resource.
    static let addWater = DeveloperToolsSupport.ImageResource(name: "AddWater", bundle: resourceBundle)

    /// The "AddWeight" asset catalog image resource.
    static let addWeight = DeveloperToolsSupport.ImageResource(name: "AddWeight", bundle: resourceBundle)

    /// The "BMChest" asset catalog image resource.
    static let bmChest = DeveloperToolsSupport.ImageResource(name: "BMChest", bundle: resourceBundle)

    /// The "BMDefault" asset catalog image resource.
    static let bmDefault = DeveloperToolsSupport.ImageResource(name: "BMDefault", bundle: resourceBundle)

    /// The "BMHips" asset catalog image resource.
    static let bmHips = DeveloperToolsSupport.ImageResource(name: "BMHips", bundle: resourceBundle)

    /// The "BMLArm" asset catalog image resource.
    static let bmlArm = DeveloperToolsSupport.ImageResource(name: "BMLArm", bundle: resourceBundle)

    /// The "BMLThigh" asset catalog image resource.
    static let bmlThigh = DeveloperToolsSupport.ImageResource(name: "BMLThigh", bundle: resourceBundle)

    /// The "BMR" asset catalog image resource.
    static let BMR = DeveloperToolsSupport.ImageResource(name: "BMR", bundle: resourceBundle)

    /// The "BMRArm" asset catalog image resource.
    static let bmrArm = DeveloperToolsSupport.ImageResource(name: "BMRArm", bundle: resourceBundle)

    /// The "BMRThigh" asset catalog image resource.
    static let bmrThigh = DeveloperToolsSupport.ImageResource(name: "BMRThigh", bundle: resourceBundle)

    /// The "BMWaist" asset catalog image resource.
    static let bmWaist = DeveloperToolsSupport.ImageResource(name: "BMWaist", bundle: resourceBundle)

    /// The "BarCode" asset catalog image resource.
    static let barCode = DeveloperToolsSupport.ImageResource(name: "BarCode", bundle: resourceBundle)

    /// The "Baseball" asset catalog image resource.
    static let baseball = DeveloperToolsSupport.ImageResource(name: "Baseball", bundle: resourceBundle)

    /// The "Basketball" asset catalog image resource.
    static let basketball = DeveloperToolsSupport.ImageResource(name: "Basketball", bundle: resourceBundle)

    /// The "Bikeing" asset catalog image resource.
    static let bikeing = DeveloperToolsSupport.ImageResource(name: "Bikeing", bundle: resourceBundle)

    /// The "Boxing" asset catalog image resource.
    static let boxing = DeveloperToolsSupport.ImageResource(name: "Boxing", bundle: resourceBundle)

    /// The "CalW" asset catalog image resource.
    static let calW = DeveloperToolsSupport.ImageResource(name: "CalW", bundle: resourceBundle)

    /// The "CustomActivity" asset catalog image resource.
    static let customActivity = DeveloperToolsSupport.ImageResource(name: "CustomActivity", bundle: resourceBundle)

    /// The "DefaultFood" asset catalog image resource.
    static let defaultFood = DeveloperToolsSupport.ImageResource(name: "DefaultFood", bundle: resourceBundle)

    /// The "DefaultWorkout" asset catalog image resource.
    static let defaultWorkout = DeveloperToolsSupport.ImageResource(name: "DefaultWorkout", bundle: resourceBundle)

    /// The "Eliptical" asset catalog image resource.
    static let eliptical = DeveloperToolsSupport.ImageResource(name: "Eliptical", bundle: resourceBundle)

    /// The "Empty man PP" asset catalog image resource.
    static let emptyManPP = DeveloperToolsSupport.ImageResource(name: "Empty man PP", bundle: resourceBundle)

    /// The "Empty woman PP" asset catalog image resource.
    static let emptyWomanPP = DeveloperToolsSupport.ImageResource(name: "Empty woman PP", bundle: resourceBundle)

    /// The "Golf" asset catalog image resource.
    static let golf = DeveloperToolsSupport.ImageResource(name: "Golf", bundle: resourceBundle)

    /// The "Hiking" asset catalog image resource.
    static let hiking = DeveloperToolsSupport.ImageResource(name: "Hiking", bundle: resourceBundle)

    /// The "Hockey" asset catalog image resource.
    static let hockey = DeveloperToolsSupport.ImageResource(name: "Hockey", bundle: resourceBundle)

    /// The "LeftFoot" asset catalog image resource.
    static let leftFoot = DeveloperToolsSupport.ImageResource(name: "LeftFoot", bundle: resourceBundle)

    /// The "MountainBike" asset catalog image resource.
    static let mountainBike = DeveloperToolsSupport.ImageResource(name: "MountainBike", bundle: resourceBundle)

    /// The "Paddle" asset catalog image resource.
    static let paddle = DeveloperToolsSupport.ImageResource(name: "Paddle", bundle: resourceBundle)

    /// The "Pickle" asset catalog image resource.
    static let pickle = DeveloperToolsSupport.ImageResource(name: "Pickle", bundle: resourceBundle)

    /// The "Pilates" asset catalog image resource.
    static let pilates = DeveloperToolsSupport.ImageResource(name: "Pilates", bundle: resourceBundle)

    /// The "RightFoot" asset catalog image resource.
    static let rightFoot = DeveloperToolsSupport.ImageResource(name: "RightFoot", bundle: resourceBundle)

    /// The "Rockclimbing" asset catalog image resource.
    static let rockclimbing = DeveloperToolsSupport.ImageResource(name: "Rockclimbing", bundle: resourceBundle)

    /// The "Rowing" asset catalog image resource.
    static let rowing = DeveloperToolsSupport.ImageResource(name: "Rowing", bundle: resourceBundle)

    /// The "Running" asset catalog image resource.
    static let running = DeveloperToolsSupport.ImageResource(name: "Running", bundle: resourceBundle)

    /// The "ShuttleCock" asset catalog image resource.
    static let shuttleCock = DeveloperToolsSupport.ImageResource(name: "ShuttleCock", bundle: resourceBundle)

    /// The "Skiing" asset catalog image resource.
    static let skiing = DeveloperToolsSupport.ImageResource(name: "Skiing", bundle: resourceBundle)

    /// The "SliderIcon" asset catalog image resource.
    static let sliderIcon = DeveloperToolsSupport.ImageResource(name: "SliderIcon", bundle: resourceBundle)

    /// The "SliderIconDark" asset catalog image resource.
    static let sliderIconDark = DeveloperToolsSupport.ImageResource(name: "SliderIconDark", bundle: resourceBundle)

    /// The "Snowboarding" asset catalog image resource.
    static let snowboarding = DeveloperToolsSupport.ImageResource(name: "Snowboarding", bundle: resourceBundle)

    /// The "Soccer" asset catalog image resource.
    static let soccer = DeveloperToolsSupport.ImageResource(name: "Soccer", bundle: resourceBundle)

    /// The "Spining" asset catalog image resource.
    static let spining = DeveloperToolsSupport.ImageResource(name: "Spining", bundle: resourceBundle)

    /// The "Swiming" asset catalog image resource.
    static let swiming = DeveloperToolsSupport.ImageResource(name: "Swiming", bundle: resourceBundle)

    /// The "Walking" asset catalog image resource.
    static let walking = DeveloperToolsSupport.ImageResource(name: "Walking", bundle: resourceBundle)

    /// The "WaterInput" asset catalog image resource.
    static let waterInput = DeveloperToolsSupport.ImageResource(name: "WaterInput", bundle: resourceBundle)

    /// The "Weights" asset catalog image resource.
    static let weights = DeveloperToolsSupport.ImageResource(name: "Weights", bundle: resourceBundle)

    /// The "XSkiing" asset catalog image resource.
    static let xSkiing = DeveloperToolsSupport.ImageResource(name: "XSkiing", bundle: resourceBundle)

    /// The "Yoga" asset catalog image resource.
    static let yoga = DeveloperToolsSupport.ImageResource(name: "Yoga", bundle: resourceBundle)

    /// The "Zumba" asset catalog image resource.
    static let zumba = DeveloperToolsSupport.ImageResource(name: "Zumba", bundle: resourceBundle)

    /// The "age" asset catalog image resource.
    static let age = DeveloperToolsSupport.ImageResource(name: "age", bundle: resourceBundle)

    /// The "bike" asset catalog image resource.
    static let bike = DeveloperToolsSupport.ImageResource(name: "bike", bundle: resourceBundle)

    /// The "bolt" asset catalog image resource.
    static let bolt = DeveloperToolsSupport.ImageResource(name: "bolt", bundle: resourceBundle)

    /// The "calender" asset catalog image resource.
    static let calender = DeveloperToolsSupport.ImageResource(name: "calender", bundle: resourceBundle)

    /// The "calisthenics" asset catalog image resource.
    static let calisthenics = DeveloperToolsSupport.ImageResource(name: "calisthenics", bundle: resourceBundle)

    /// The "drop" asset catalog image resource.
    static let drop = DeveloperToolsSupport.ImageResource(name: "drop", bundle: resourceBundle)

    /// The "flame" asset catalog image resource.
    static let flame = DeveloperToolsSupport.ImageResource(name: "flame", bundle: resourceBundle)

    /// The "food" asset catalog image resource.
    static let food = DeveloperToolsSupport.ImageResource(name: "food", bundle: resourceBundle)

    /// The "grayscaleIndicator" asset catalog image resource.
    static let grayscaleIndicator = DeveloperToolsSupport.ImageResource(name: "grayscaleIndicator", bundle: resourceBundle)

    /// The "hungry" asset catalog image resource.
    static let hungry = DeveloperToolsSupport.ImageResource(name: "hungry", bundle: resourceBundle)

    /// The "logo" asset catalog image resource.
    static let logo = DeveloperToolsSupport.ImageResource(name: "logo", bundle: resourceBundle)

    /// The "manorwoman" asset catalog image resource.
    static let manorwoman = DeveloperToolsSupport.ImageResource(name: "manorwoman", bundle: resourceBundle)

    /// The "racquetball" asset catalog image resource.
    static let racquetball = DeveloperToolsSupport.ImageResource(name: "racquetball", bundle: resourceBundle)

    /// The "scale" asset catalog image resource.
    static let scale = DeveloperToolsSupport.ImageResource(name: "scale", bundle: resourceBundle)

    /// The "scaleIndicator" asset catalog image resource.
    static let scaleIndicator = DeveloperToolsSupport.ImageResource(name: "scaleIndicator", bundle: resourceBundle)

    /// The "scuba" asset catalog image resource.
    static let scuba = DeveloperToolsSupport.ImageResource(name: "scuba", bundle: resourceBundle)

    /// The "stats" asset catalog image resource.
    static let stats = DeveloperToolsSupport.ImageResource(name: "stats", bundle: resourceBundle)

    /// The "tape" asset catalog image resource.
    static let tape = DeveloperToolsSupport.ImageResource(name: "tape", bundle: resourceBundle)

    /// The "target" asset catalog image resource.
    static let target = DeveloperToolsSupport.ImageResource(name: "target", bundle: resourceBundle)

    /// The "tennis" asset catalog image resource.
    static let tennis = DeveloperToolsSupport.ImageResource(name: "tennis", bundle: resourceBundle)

    /// The "trophy" asset catalog image resource.
    static let trophy = DeveloperToolsSupport.ImageResource(name: "trophy", bundle: resourceBundle)

    /// The "volley" asset catalog image resource.
    static let volley = DeveloperToolsSupport.ImageResource(name: "volley", bundle: resourceBundle)

    /// The "water" asset catalog image resource.
    static let water = DeveloperToolsSupport.ImageResource(name: "water", bundle: resourceBundle)

    /// The "workout" asset catalog image resource.
    static let workout = DeveloperToolsSupport.ImageResource(name: "workout", bundle: resourceBundle)

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

    /// The "ABS" asset catalog image.
    static var ABS: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .ABS)
#else
        .init()
#endif
    }

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

    /// The "AddCustom" asset catalog image.
    static var addCustom: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .addCustom)
#else
        .init()
#endif
    }

    /// The "AddFood" asset catalog image.
    static var addFood: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .addFood)
#else
        .init()
#endif
    }

    /// The "AddWater" asset catalog image.
    static var addWater: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .addWater)
#else
        .init()
#endif
    }

    /// The "AddWeight" asset catalog image.
    static var addWeight: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .addWeight)
#else
        .init()
#endif
    }

    /// The "BMChest" asset catalog image.
    static var bmChest: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .bmChest)
#else
        .init()
#endif
    }

    /// The "BMDefault" asset catalog image.
    static var bmDefault: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .bmDefault)
#else
        .init()
#endif
    }

    /// The "BMHips" asset catalog image.
    static var bmHips: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .bmHips)
#else
        .init()
#endif
    }

    /// The "BMLArm" asset catalog image.
    static var bmlArm: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .bmlArm)
#else
        .init()
#endif
    }

    /// The "BMLThigh" asset catalog image.
    static var bmlThigh: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .bmlThigh)
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

    /// The "BMRArm" asset catalog image.
    static var bmrArm: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .bmrArm)
#else
        .init()
#endif
    }

    /// The "BMRThigh" asset catalog image.
    static var bmrThigh: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .bmrThigh)
#else
        .init()
#endif
    }

    /// The "BMWaist" asset catalog image.
    static var bmWaist: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .bmWaist)
#else
        .init()
#endif
    }

    /// The "BarCode" asset catalog image.
    static var barCode: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .barCode)
#else
        .init()
#endif
    }

    /// The "Baseball" asset catalog image.
    static var baseball: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .baseball)
#else
        .init()
#endif
    }

    /// The "Basketball" asset catalog image.
    static var basketball: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .basketball)
#else
        .init()
#endif
    }

    /// The "Bikeing" asset catalog image.
    static var bikeing: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .bikeing)
#else
        .init()
#endif
    }

    /// The "Boxing" asset catalog image.
    static var boxing: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .boxing)
#else
        .init()
#endif
    }

    /// The "CalW" asset catalog image.
    static var calW: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .calW)
#else
        .init()
#endif
    }

    /// The "CustomActivity" asset catalog image.
    static var customActivity: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .customActivity)
#else
        .init()
#endif
    }

    /// The "DefaultFood" asset catalog image.
    static var defaultFood: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .defaultFood)
#else
        .init()
#endif
    }

    /// The "DefaultWorkout" asset catalog image.
    static var defaultWorkout: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .defaultWorkout)
#else
        .init()
#endif
    }

    /// The "Eliptical" asset catalog image.
    static var eliptical: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .eliptical)
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

    /// The "Golf" asset catalog image.
    static var golf: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .golf)
#else
        .init()
#endif
    }

    /// The "Hiking" asset catalog image.
    static var hiking: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .hiking)
#else
        .init()
#endif
    }

    /// The "Hockey" asset catalog image.
    static var hockey: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .hockey)
#else
        .init()
#endif
    }

    /// The "LeftFoot" asset catalog image.
    static var leftFoot: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .leftFoot)
#else
        .init()
#endif
    }

    /// The "MountainBike" asset catalog image.
    static var mountainBike: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mountainBike)
#else
        .init()
#endif
    }

    /// The "Paddle" asset catalog image.
    static var paddle: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .paddle)
#else
        .init()
#endif
    }

    /// The "Pickle" asset catalog image.
    static var pickle: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .pickle)
#else
        .init()
#endif
    }

    /// The "Pilates" asset catalog image.
    static var pilates: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .pilates)
#else
        .init()
#endif
    }

    /// The "RightFoot" asset catalog image.
    static var rightFoot: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .rightFoot)
#else
        .init()
#endif
    }

    /// The "Rockclimbing" asset catalog image.
    static var rockclimbing: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .rockclimbing)
#else
        .init()
#endif
    }

    /// The "Rowing" asset catalog image.
    static var rowing: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .rowing)
#else
        .init()
#endif
    }

    /// The "Running" asset catalog image.
    static var running: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .running)
#else
        .init()
#endif
    }

    /// The "ShuttleCock" asset catalog image.
    static var shuttleCock: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .shuttleCock)
#else
        .init()
#endif
    }

    /// The "Skiing" asset catalog image.
    static var skiing: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .skiing)
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

    /// The "SliderIconDark" asset catalog image.
    static var sliderIconDark: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .sliderIconDark)
#else
        .init()
#endif
    }

    /// The "Snowboarding" asset catalog image.
    static var snowboarding: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .snowboarding)
#else
        .init()
#endif
    }

    /// The "Soccer" asset catalog image.
    static var soccer: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .soccer)
#else
        .init()
#endif
    }

    /// The "Spining" asset catalog image.
    static var spining: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .spining)
#else
        .init()
#endif
    }

    /// The "Swiming" asset catalog image.
    static var swiming: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .swiming)
#else
        .init()
#endif
    }

    /// The "Walking" asset catalog image.
    static var walking: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .walking)
#else
        .init()
#endif
    }

    /// The "WaterInput" asset catalog image.
    static var waterInput: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .waterInput)
#else
        .init()
#endif
    }

    /// The "Weights" asset catalog image.
    static var weights: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .weights)
#else
        .init()
#endif
    }

    /// The "XSkiing" asset catalog image.
    static var xSkiing: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .xSkiing)
#else
        .init()
#endif
    }

    /// The "Yoga" asset catalog image.
    static var yoga: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .yoga)
#else
        .init()
#endif
    }

    /// The "Zumba" asset catalog image.
    static var zumba: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .zumba)
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

    /// The "calisthenics" asset catalog image.
    static var calisthenics: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .calisthenics)
#else
        .init()
#endif
    }

    /// The "drop" asset catalog image.
    static var drop: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .drop)
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

    /// The "food" asset catalog image.
    static var food: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .food)
#else
        .init()
#endif
    }

    /// The "grayscaleIndicator" asset catalog image.
    static var grayscaleIndicator: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .grayscaleIndicator)
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

    /// The "racquetball" asset catalog image.
    static var racquetball: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .racquetball)
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

    /// The "scuba" asset catalog image.
    static var scuba: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .scuba)
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

    /// The "tennis" asset catalog image.
    static var tennis: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tennis)
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

    /// The "volley" asset catalog image.
    static var volley: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .volley)
#else
        .init()
#endif
    }

    /// The "water" asset catalog image.
    static var water: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .water)
#else
        .init()
#endif
    }

    /// The "workout" asset catalog image.
    static var workout: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .workout)
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

    /// The "ABS" asset catalog image.
    static var ABS: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .ABS)
#else
        .init()
#endif
    }

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

    /// The "AddCustom" asset catalog image.
    static var addCustom: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .addCustom)
#else
        .init()
#endif
    }

    /// The "AddFood" asset catalog image.
    static var addFood: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .addFood)
#else
        .init()
#endif
    }

    /// The "AddWater" asset catalog image.
    static var addWater: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .addWater)
#else
        .init()
#endif
    }

    /// The "AddWeight" asset catalog image.
    static var addWeight: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .addWeight)
#else
        .init()
#endif
    }

    /// The "BMChest" asset catalog image.
    static var bmChest: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .bmChest)
#else
        .init()
#endif
    }

    /// The "BMDefault" asset catalog image.
    static var bmDefault: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .bmDefault)
#else
        .init()
#endif
    }

    /// The "BMHips" asset catalog image.
    static var bmHips: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .bmHips)
#else
        .init()
#endif
    }

    /// The "BMLArm" asset catalog image.
    static var bmlArm: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .bmlArm)
#else
        .init()
#endif
    }

    /// The "BMLThigh" asset catalog image.
    static var bmlThigh: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .bmlThigh)
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

    /// The "BMRArm" asset catalog image.
    static var bmrArm: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .bmrArm)
#else
        .init()
#endif
    }

    /// The "BMRThigh" asset catalog image.
    static var bmrThigh: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .bmrThigh)
#else
        .init()
#endif
    }

    /// The "BMWaist" asset catalog image.
    static var bmWaist: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .bmWaist)
#else
        .init()
#endif
    }

    /// The "BarCode" asset catalog image.
    static var barCode: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .barCode)
#else
        .init()
#endif
    }

    /// The "Baseball" asset catalog image.
    static var baseball: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .baseball)
#else
        .init()
#endif
    }

    /// The "Basketball" asset catalog image.
    static var basketball: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .basketball)
#else
        .init()
#endif
    }

    /// The "Bikeing" asset catalog image.
    static var bikeing: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .bikeing)
#else
        .init()
#endif
    }

    /// The "Boxing" asset catalog image.
    static var boxing: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .boxing)
#else
        .init()
#endif
    }

    /// The "CalW" asset catalog image.
    static var calW: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .calW)
#else
        .init()
#endif
    }

    /// The "CustomActivity" asset catalog image.
    static var customActivity: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .customActivity)
#else
        .init()
#endif
    }

    /// The "DefaultFood" asset catalog image.
    static var defaultFood: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .defaultFood)
#else
        .init()
#endif
    }

    /// The "DefaultWorkout" asset catalog image.
    static var defaultWorkout: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .defaultWorkout)
#else
        .init()
#endif
    }

    /// The "Eliptical" asset catalog image.
    static var eliptical: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .eliptical)
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

    /// The "Golf" asset catalog image.
    static var golf: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .golf)
#else
        .init()
#endif
    }

    /// The "Hiking" asset catalog image.
    static var hiking: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .hiking)
#else
        .init()
#endif
    }

    /// The "Hockey" asset catalog image.
    static var hockey: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .hockey)
#else
        .init()
#endif
    }

    /// The "LeftFoot" asset catalog image.
    static var leftFoot: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .leftFoot)
#else
        .init()
#endif
    }

    /// The "MountainBike" asset catalog image.
    static var mountainBike: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mountainBike)
#else
        .init()
#endif
    }

    /// The "Paddle" asset catalog image.
    static var paddle: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .paddle)
#else
        .init()
#endif
    }

    /// The "Pickle" asset catalog image.
    static var pickle: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .pickle)
#else
        .init()
#endif
    }

    /// The "Pilates" asset catalog image.
    static var pilates: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .pilates)
#else
        .init()
#endif
    }

    /// The "RightFoot" asset catalog image.
    static var rightFoot: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .rightFoot)
#else
        .init()
#endif
    }

    /// The "Rockclimbing" asset catalog image.
    static var rockclimbing: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .rockclimbing)
#else
        .init()
#endif
    }

    /// The "Rowing" asset catalog image.
    static var rowing: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .rowing)
#else
        .init()
#endif
    }

    /// The "Running" asset catalog image.
    static var running: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .running)
#else
        .init()
#endif
    }

    /// The "ShuttleCock" asset catalog image.
    static var shuttleCock: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .shuttleCock)
#else
        .init()
#endif
    }

    /// The "Skiing" asset catalog image.
    static var skiing: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .skiing)
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

    /// The "SliderIconDark" asset catalog image.
    static var sliderIconDark: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .sliderIconDark)
#else
        .init()
#endif
    }

    /// The "Snowboarding" asset catalog image.
    static var snowboarding: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .snowboarding)
#else
        .init()
#endif
    }

    /// The "Soccer" asset catalog image.
    static var soccer: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .soccer)
#else
        .init()
#endif
    }

    /// The "Spining" asset catalog image.
    static var spining: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .spining)
#else
        .init()
#endif
    }

    /// The "Swiming" asset catalog image.
    static var swiming: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .swiming)
#else
        .init()
#endif
    }

    /// The "Walking" asset catalog image.
    static var walking: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .walking)
#else
        .init()
#endif
    }

    /// The "WaterInput" asset catalog image.
    static var waterInput: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .waterInput)
#else
        .init()
#endif
    }

    /// The "Weights" asset catalog image.
    static var weights: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .weights)
#else
        .init()
#endif
    }

    /// The "XSkiing" asset catalog image.
    static var xSkiing: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .xSkiing)
#else
        .init()
#endif
    }

    /// The "Yoga" asset catalog image.
    static var yoga: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .yoga)
#else
        .init()
#endif
    }

    /// The "Zumba" asset catalog image.
    static var zumba: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .zumba)
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

    /// The "calisthenics" asset catalog image.
    static var calisthenics: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .calisthenics)
#else
        .init()
#endif
    }

    /// The "drop" asset catalog image.
    static var drop: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .drop)
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

    /// The "food" asset catalog image.
    static var food: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .food)
#else
        .init()
#endif
    }

    /// The "grayscaleIndicator" asset catalog image.
    static var grayscaleIndicator: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .grayscaleIndicator)
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

    /// The "racquetball" asset catalog image.
    static var racquetball: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .racquetball)
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

    /// The "scuba" asset catalog image.
    static var scuba: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .scuba)
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

    /// The "tennis" asset catalog image.
    static var tennis: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tennis)
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

    /// The "volley" asset catalog image.
    static var volley: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .volley)
#else
        .init()
#endif
    }

    /// The "water" asset catalog image.
    static var water: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .water)
#else
        .init()
#endif
    }

    /// The "workout" asset catalog image.
    static var workout: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .workout)
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

