//
//  BarChartModel.swift
//  Pace Cloud
//
//  Created by rgl on 21/10/19.
//  Copyright © 2019 royalgreen. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

/// The data model for a single chart bar.
class BarChart: ObservableObject {
    /// Full chart width
    var fullChartWidth = 0.0
    var fullChartHeight = 0.0
    var maxBarValue = 0.0
    var chartColors = [ChartColor(hue: 0.2242, saturation: 0.4701, brightness: 0.9176),
                       ChartColor(hue: 0.3781, saturation: 0.9459, brightness: 0.7255),
                       ChartColor(hue: 0.1253, saturation: 1.0000, brightness: 0.9961),
                       ChartColor(hue: 0.5164, saturation: 1.0000, brightness: 0.9961),
                       ChartColor(hue: 0.4188, saturation: 1.0000, brightness: 0.9020),
                       ChartColor(hue: 0.1529, saturation: 1.0000, brightness: 1.0000),
                       ChartColor(hue: 0.5333, saturation: 1.0000, brightness: 0.9804),
                       ChartColor(hue: 0.0786, saturation: 0.7628, brightness: 0.9922),
                       ChartColor(hue: 0.6044, saturation: 0.8392, brightness: 1.0000),
                       ChartColor(hue: 0.2039, saturation: 1.0000, brightness: 1.0000)]
    /// The collection of wedges, tracked by their id.
    var bars: [Int: BarColumn] {
        get {
            if _barsNeedUpdate {
                /// Recalculate each bar height and width, to pack within the chart view.
                for id in barIDs {
                    var bar = _bars[id]!
                    bar.width = (fullChartWidth - ((Double(barIDs.count) + 1) * 8)) / Double(barIDs.count)
                    bar.height = (fullChartHeight / maxBarValue) * bar.chartValue
                    _bars[id] = bar
                }
                _barsNeedUpdate = false
            }
            return _bars
        }
        set {
            objectWillChange.send()
            _bars = newValue
            _barsNeedUpdate = true
        }
    }
    
    private var _bars = [Int: BarColumn]()
    private var _barsNeedUpdate = false
    
    /// The display order of the wedges.
    private(set) var barIDs = [Int]() {
        willSet {
            objectWillChange.send()
        }
    }
    
    /// The next id to allocate.
    private var nextID = 0
    
    /// Trivial publisher for our changes.
    let objectWillChange = PassthroughSubject<Void, Never>()
    
    /// Adds a new wedge description to `array`.
    func addBar(_ value: BarColumn) {
        var newBar = value
        if chartColors.count > nextID {
            newBar.hue = chartColors[nextID].hue
            newBar.saturation = chartColors[nextID].saturation
            newBar.brightness = chartColors[nextID].brightness
        }
        let id = nextID
        nextID += 1
        bars[id] = newBar
        barIDs.append(id)
        if newBar.chartValue > maxBarValue {
            maxBarValue = newBar.chartValue
        }
    }
    
    /// Removes the wedge with `id`.
    func removeWedge(id: Int) {
        if let indexToRemove = barIDs.firstIndex(where: { $0 == id }) {
            barIDs.remove(at: indexToRemove)
            bars.removeValue(forKey: id)
        }
    }
    
    /// Clear all data.
    func reset() {
        if !barIDs.isEmpty {
            barIDs = []
            bars = [:]
            nextID = 0
        }
    }
}

/// A single wedge within a chart ring.
struct BarColumn: Equatable {
    /// Chart value
    var chartValue: Double
    /// Chart label
    var label: String
    /// The wedge's height, as an angle in radians.
    var height = 0.0
    /// The wedge's cross-axis depth, in range [0,1].
    var width = 0.0
    /// The ring's hue.
    var hue: Double
    var saturation: Double
    var brightness: Double
}

struct ChartColor: Equatable {
    var hue: Double
    var saturation: Double
    var brightness: Double
}

/// Extend the wedge description to conform to the Animatable type to
/// simplify creation of custom shapes using the wedge.
extension BarColumn: Animatable {
    // Use a composition of pairs to merge the interpolated values into
    // a single type. AnimatablePair acts as a single interpolatable
    // values, given two interpolatable input types.
    
    // We'll interpolate the derived start/end angles, and the depth
    // and color values. The width parameter is not used for rendering,
    // and so doesn't need to be interpolated.
    
    typealias AnimatableData = AnimatablePair<
        AnimatablePair<Double, Double>, AnimatablePair<Double, Double>>
    
    var animatableData: AnimatableData {
        get {
            .init(.init(height, hue), .init(saturation, brightness))
        }
        set {
            height = newValue.first.first
            hue = newValue.first.second
            saturation = newValue.second.first
            brightness = newValue.second.second
        }
    }
}
