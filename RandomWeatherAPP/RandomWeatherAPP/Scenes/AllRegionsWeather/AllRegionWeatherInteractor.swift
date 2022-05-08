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
    
    var viewModel: LocationsWeatherViewModel { get set }
}

class AllRegionWeatherInteractor: AllRegionWeatherInteractorMethods {
    
    let locationService: LocationWeatherServiceMethods
    var cancelBag = Set<AnyCancellable>()
    @ObservedObject var viewModel: LocationsWeatherViewModel = LocationsWeatherViewModel()
    
    let locations: [String] = ["44418", // London
                               "890869", //Gothenburg
                               "906057", //Stockholm
                               "2455920", //Mountain View
                               "2459115", //New York
                               "638242"] //Berlin
    
    init(locationService: LocationWeatherServiceMethods = LocationWeatherService()) {
        self.locationService = locationService
    }
    
    func loadDatas() {
        for location in locations {
            locationService.getWeather(for: location)
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { _ in
                    print("completed")
                },
                      receiveValue: { [weak self] response in
                    let actualTemp = response.consolidatedWeather.first?.theTemp ?? 0.0
                    let nextDaysWeather = response.consolidatedWeather.map{ weather in
                        return DayWeather(minTemp: weather.minTemp, maxTemp: weather.maxTemp, date: weather.applicableDate)
                    }
                    let model = LocationModel(title: response.title, country: response.parent.title, actualTemp: actualTemp, nextDaysWeather: nextDaysWeather)
                    self?.viewModel.models.append(model)
                }).store(in: &cancelBag)
        }
    }
    
    func showMoreDetails(for city: String) {
        guard let model = viewModel.models.first(where: { $0.title == city }),
              let index = viewModel.models.firstIndex(where: { $0.title == city })
        else { return }

        model.detailHidden.toggle()
        viewModel.models.insert(model, at: index)
        viewModel.models.remove(at: index)
    }
}

class LocationsWeatherViewModel: ObservableObject {
    @Published var models: [LocationModel] = []
}

class LocationModel: ObservableObject, Identifiable {
    var id = UUID()
    @Published var title: String
    @Published var country: String
    @Published var actualTemp: Double
    @Published var nextDaysWeather: [DayWeather]
    @Published var detailHidden = true
    
    init(title: String, country: String, actualTemp: Double, nextDaysWeather: [DayWeather]) {
        self.title = title
        self.country = country
        self.actualTemp = actualTemp
        self.nextDaysWeather = nextDaysWeather
    }
}

class DayWeather: ObservableObject, Identifiable {
    let id = UUID()
    @Published var minTemp: Double
    @Published var maxTemp: Double
    @Published var date: String
    
    init(minTemp: Double, maxTemp: Double, date: String) {
        self.minTemp = minTemp
        self.maxTemp = maxTemp
        self.date = date
    }
}
