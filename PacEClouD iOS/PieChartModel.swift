//
//  PieChartModel.swift
//  Pace Cloud
//
//  Created by rgl on 20/10/19.
//  Copyright © 2019 royalgreen. All rights reserved.
//


import SwiftUI
import Combine

/// The data model for a single chart ring.
class Ring: ObservableObject {
    /// Full circle angle in radian e.g. 360 degree = 6.28319 radian
    let fullCircleLengthInRadius = 6.28319
    var totalWedgesWidth = 0.0
    /// The collection of wedges, tracked by their id.
    var wedges: [Int: Wedge] {
        get {
            if _wedgesNeedUpdate {
                /// Recalculate locations, to pack within circle.
                let total = wedgeIDs.reduce(0.0) { $0 + _wedges[$1]!.width }
                let scale = (.pi * 2) / max(.pi * 2, total)
                var location = 0.0
                for id in wedgeIDs {
                    var wedge = _wedges[id]!
                    wedge.width = (fullCircleLengthInRadius * wedge.chartValue)/totalWedgesWidth
                    if wedgeIDs.count > 1 {
                        wedge.start = location * scale + 0.03
                    } else {
                        wedge.start = location * scale
                    }
                    location += wedge.width
                    wedge.end = location * scale
                    _wedges[id] = wedge
                }
                _wedgesNeedUpdate = false
            }
            return _wedges
        }
        set {
            objectWillChange.send()
            _wedges = newValue
            _wedgesNeedUpdate = true
        }
    }
    
    private var _wedges = [Int: Wedge]()
    private var _wedgesNeedUpdate = false
    
    /// The display order of the wedges.
    private(set) var wedgeIDs = [Int]() {
        willSet {
            objectWillChange.send()
        }
    }
    
    /// When true, periodically updates the data with random changes.
    //    var randomWalk = false { didSet { updateTimer() } }
    
    /// The next id to allocate.
    private var nextID = 0
    
    /// Trivial publisher for our changes.
    let objectWillChange = PassthroughSubject<Void, Never>()
    
    /// Adds a new wedge description to `array`.
    func addWedge(_ value: Wedge) {
        let id = nextID
        nextID += 1
        totalWedgesWidth += value.chartValue
        wedges[id] = value
        wedgeIDs.append(id)
    }
    
    func wedgeOnTapped(id: Int) {
        guard var tappedWedge = wedges[id] else {
            return
        }
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.3)) {
            if tappedWedge.isTapped {
                tappedWedge.depth -= 0.075
                tappedWedge.isTapped = false
            } else {
                tappedWedge.depth += 0.075
                tappedWedge.isTapped = true
            }
            wedges[id] = tappedWedge
            for (id, value) in wedges {
                if value != tappedWedge && value.isTapped == true{
                    guard var wedge = wedges[id] else {
                        return
                    }
                    wedge.depth -= 0.075
                    wedge.isTapped = false
                    wedges[id] = wedge
                }
            }
        }
    }
    
    /// Removes the wedge with `id`.
    func removeWedge(id: Int) {
        if let indexToRemove = wedgeIDs.firstIndex(where: { $0 == id }) {
            wedgeIDs.remove(at: indexToRemove)
            wedges.removeValue(forKey: id)
        }
    }
    
    /// Clear all data.
    func reset() {
        if !wedgeIDs.isEmpty {
            wedgeIDs = []
            wedges = [:]
            totalWedgesWidth = 0.0
            nextID = 0
        }
    }
}

/// A single wedge within a chart ring.
struct Wedge: Equatable {
    var label: String
    /// Chart value
    var chartValue: Double
    /// The wedge's width, as an angle in radians.
    var width = 0.0
    /// The wedge's cross-axis depth, in range [0,1].
    var depth = 1.0
    /// The ring's hue.
    var hue: Double
    var saturation: Double
    var brightness: Double
    /// Verifies whether this wedge is tapped or not
    var isTapped = false
    
    /// The wedge's start location, as an angle in radians.
    fileprivate(set) var start = 0.0
    /// The wedge's end location, as an angle in radians.
    fileprivate(set) var end = 0.0
}

/// Extend the wedge description to conform to the Animatable type to
/// simplify creation of custom shapes using the wedge.
extension Wedge: Animatable {
    // Use a composition of pairs to merge the interpolated values into
    // a single type. AnimatablePair acts as a single interpolatable
    // values, given two interpolatable input types.
    
    // We'll interpolate the derived start/end angles, and the depth
    // and color values. The width parameter is not used for rendering,
    // and so doesn't need to be interpolated.
    
    typealias AnimatableData = AnimatablePair<
        AnimatablePair<Double, Double>, AnimatablePair<AnimatablePair<Double, Double>, AnimatablePair<Double, Double>>>
    
    var animatableData: AnimatableData {
        get {
            .init(.init(start, end), .init(.init(depth, hue), .init(saturation, brightness)))
        }
        set {
            start = newValue.first.first
            end = newValue.first.second
            depth = newValue.second.first.first
            hue = newValue.second.first.second
            saturation = newValue.second.second.first
            brightness = newValue.second.second.second
        }
    }
}
