//
//  ClientsView.swift
//  Bookaloo
//
//  Created by Joyce Rosario Batista on 1/2/23.
//

import SwiftUI

struct ClientsView: View {
    @ObservedObject var viewModel: ClientsViewModel
    
    var body: some View {
        BaseViewContent(viewModel: viewModel) {
            VStack {
                Text("Clients")
            }
        }
    }
}

struct ClientsView_Previews: PreviewProvider {
    static var previews: some View {
        ModuleDependencies().clientsView()
    }
}
