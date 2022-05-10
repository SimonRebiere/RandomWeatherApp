//
//  AllRegionWeatherView.swift
//  RandomWeatherAPP
//
//  Created by simon rebiere on 01/05/2022.
//

import SwiftUI

struct AllRegionWeatherView: View {
    let interactor: AllRegionWeatherInteractorMethods
    @ObservedObject var viewModel: LocationsWeatherViewModel
    
    init(interactor: AllRegionWeatherInteractorMethods = AllRegionWeatherInteractor()) {
        self.interactor = interactor
        self.viewModel = interactor.viewModel
    }
    
    var body: some View {
        NavigationView {
            List(viewModel.models) {  model in
                VStack {
                    HStack {
                        Spacer()
                        VStack(alignment: .center) {
                            
                            Text("\(model.title) - \(model.country)")
                            Text(model.state)
                            Text("\(String(format: "%.1f", model.actualTemp))C°")
                        }.onTapGesture {
                            interactor.showMoreDetails(for: model.title)
                        }
                        Spacer()
                        AsyncImage(url: model.imageURL)
                            .aspectRatio(contentMode: .fit)
                    }
                    if !model.detailHidden {
                        ScrollView(.horizontal) {
                            HStack(spacing: 8) {
                                ForEach(model.nextDaysWeather) { weather in
                                    WeatherCarousel(model: weather)
                                    Divider()
                                }
                            }
                        }
                    }
                }
            }
            .onAppear(perform: {
                interactor.loadDatas()
            })
        }
    }
}

struct WeatherCarousel: View {
    @ObservedObject var model: DayWeather
    
    init(model: DayWeather) {
        self.model = model
    }
    
    var body: some View {
        VStack {
            Text(model.date)
            Text("min: \(String(format: "%.1f", model.minTemp))C°")
            Text("max: \(String(format: "%.1f", model.maxTemp))C°")
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AllRegionWeatherView()
    }
}
