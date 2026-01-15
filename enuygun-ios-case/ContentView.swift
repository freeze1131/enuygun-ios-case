//
//  ContentView.swift
//  enuygun-ios-case
//
//  Created by Ahmet Ozen on 15.01.2026.
//

import SwiftUI

struct ContentView: View {

    @StateObject private var viewModel = ProductListViewModel()

    var body: some View {
        Text("Check console")
            .task {
                await viewModel.fetchProducts()
            }
    }
}


#Preview {
    ContentView()
}
