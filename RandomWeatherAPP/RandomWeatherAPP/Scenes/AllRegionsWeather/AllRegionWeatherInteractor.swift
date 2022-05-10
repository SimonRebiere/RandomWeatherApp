//
//  AllRegionWeatherInteractor.swift
//  RandomWeatherAPP
//
//  Created by simon rebiere on 01/05/2022.
//

import Foundation
import Combine
import SwiftUI

protocol AllRegionWeatherInteractorMethods {
    func loadDatas()
    func showMoreDetails(for city: String)
    
    var viewModel: LocationsWeatherViewModel { get }
}

class AllRegionWeatherInteractor: AllRegionWeatherInteractorMethods {
    
    let locationService: LocationWeatherServiceMethods
    var cancelBag = Set<AnyCancellable>()
    var viewModel: LocationsWeatherViewModel
    
    let locations: [String] = ["44418", // London
                               "890869", //Gothenburg
                               "906057", //Stockholm
                               "2455920", //Mountain View
                               "2459115", //New York
                               "638242"] //Berlin
    
    init(locationService: LocationWeatherServiceMethods = LocationWeatherService()) {
        self.locationService = locationService
        self.viewModel = LocationsWeatherViewModel()
    }
    
    func loadDatas() {
        let publishers = locations.map { locationService.getWeather(for: $0) }

        Publishers.MergeMany(publishers)
            .collect()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { _ in
                print("completed")
            },
                  receiveValue: { [weak self] responses in
                let models = responses.map { response -> LocationModel in
                    let actualTemp = response.consolidatedWeather.first?.theTemp ?? 0.0
                    let nextDaysWeather = response.consolidatedWeather.map{ weather in
                        return DayWeather(minTemp: weather.minTemp, maxTemp: weather.maxTemp, date: weather.applicableDate)
                    }

                    let state = response.consolidatedWeather.first?.weatherStateName ?? "unknown"
                    let stateAbbreviation = response.consolidatedWeather.first?.weatherStateAbbr ?? ""
                    return LocationModel(title: response.title, country: response.parent.title, actualTemp: actualTemp, nextDaysWeather: nextDaysWeather, state: state, imageURL: stateAbbreviation)
                }
                self?.viewModel.models.append(contentsOf: models)
            }).store(in: &cancelBag)
    }
    
    func showMoreDetails(for city: String) {
        guard let model = viewModel.models.first(where: { $0.title == city }),
              let index = viewModel.models.firstIndex(where: { $0.title == city })
        else { return }

        model.detailHidden.toggle()
        viewModel.models.move(fromOffsets: IndexSet(integer: index), toOffset: index)
    }
}

class LocationsWeatherViewModel: ObservableObject {
    @Published var models: [LocationModel] = []
}

class LocationModel: ObservableObject, Identifiable {
    var id = UUID()
    var title: String
    var country: String
    var actualTemp: Double
    var nextDaysWeather: [DayWeather]
    var state: String
    var imageURL: URL?
    var detailHidden = true
    
    init(title: String, country: String, actualTemp: Double, nextDaysWeather: [DayWeather], state: String, imageURL: String) {
        self.title = title
        self.country = country
        self.actualTemp = actualTemp
        self.nextDaysWeather = nextDaysWeather
        self.state = state
        self.imageURL = URL(string: "https://www.metaweather.com/static/img/weather/png/64/\(imageURL).png")
    }
}

class DayWeather: ObservableObject, Identifiable {
    let id = UUID()
    var minTemp: Double
    var maxTemp: Double
    var date: String
    
    init(minTemp: Double, maxTemp: Double, date: String) {
        self.minTemp = minTemp
        self.maxTemp = maxTemp
        self.date = date
    }
}
