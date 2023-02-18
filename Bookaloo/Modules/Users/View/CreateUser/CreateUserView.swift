//
//  CreateUserView.swift
//  Bookaloo
//
//  Created by Joyce Rosario Batista on 18/2/23.
//

import SwiftUI

struct CreateUserView: View {
    @EnvironmentObject var viewModel: UsersViewModel
    @FocusState private var isFocused: Bool
    
    var body: some View {
        BaseViewContent(viewModel: viewModel) {
            VStack(spacing: 16) {
                Spacer()
                
                HStack(alignment: .center) {
                    Text("New user")
                        .font(.futura(24))
                        .bold()
                        .opacity(0.6)
                }//: HStack
                
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Email:")
                            .font(.futura(14))
                            .bold()
                            .foregroundColor(.accentColor)
                            .opacity(0.6)
                        
                        BookalooTextfield(
                            textfieldText: $viewModel.newUser.email,
                            valid: $viewModel.validEmail,
                            validationText: viewModel.validEmailText,
                            orientation: .horizontal(.email),
                            showTextfieldIcon: false
                        )//: Textfield
                        .focused($isFocused)
                    }//: HStack - Email
                    .padding(.horizontal, 16)
                    
                    HStack {
                        Text("Name:")
                            .font(.futura(14))
                            .bold()
                            .foregroundColor(.accentColor)
                            .opacity(0.6)
                        
                        BookalooTextfield(
                            textfieldText: $viewModel.newUser.name,
                            valid: $viewModel.validName,
                            validationText: viewModel.validNotEmptyText,
                            orientation: .horizontal(.normal)
                        )//: Textfield
                        .focused($isFocused)
                    }//: HStack - Name
                    .padding(.horizontal, 16)
                    
                    HStack {
                        Text("Location:")
                            .font(.futura(14))
                            .bold()
                            .foregroundColor(.accentColor)
                            .opacity(0.6)
                        
                        BookalooTextfield(
                            textfieldText: $viewModel.newUser.location,
                            valid: $viewModel.validLocation,
                            validationText: viewModel.validNotEmptyText,
                            orientation: .horizontal(.normal)
                        )//: Textfield
                        .focused($isFocused)
                    }//: HStack - Location
                    .padding(.horizontal, 16)
                }//: VStack
                .onTapGesture {
                    isFocused = false
                }//: onTapGesture
                
                if viewModel.isAdmin {
                    HStack {
                        Text("Role:")
                            .font(.futura(14))
                            .bold()
                            .foregroundColor(.accentColor)
                            .opacity(0.6)
                        
                        Picker(selection: $viewModel.newUser.role) {
                            ForEach(Role.allCases) { role in
                                Text(role.rawValue.capitalized)
                                    .font(.futura(14))
                                    .bold()
                                    .opacity(0.7)
                            }
                        } label: {
                            Text("")
                        }//: Picker
                        
                    }//: HStack - Role
                    .padding(.horizontal, 16)
                }// Is is admin, show the role selection
                
                Spacer()
                
                Button {
                    viewModel.save()
                    isFocused.toggle()
                } label: {
                    Label("Save", systemImage: "square.and.arrow.down")
                }//: Button save
                .buttonStyle(.bookalooStyle)
                
                Spacer(minLength: 10)
                
            }//: VStack
        }//: BaseViewContent
        .padding(.bottom, 50)
        .onTapGesture {
            isFocused = false
        }//: onTapGesture
        .overlay {
            if viewModel.showCreatedUserAlert {
                createdUserPopup
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Text("Bookaloo")
                    .font(.futura(24))
                    .bold()
                    .foregroundStyle(StyleConstants.bookalooGradient)
            }//: ToolbarItem - Title
        }//: Toolbar
        .toolbar(.hidden, for: .tabBar)
        .ignoresSafeArea()
    }
}

extension CreateUserView {
    @ViewBuilder
    var createdUserPopup: some View {
        PopupView(
            showAlert: $viewModel.showCreatedUserAlert,
            title: "User created!") {
                Text("The user has been successfully created")
            } buttons: {
                Button {
                    viewModel.showCreatedUserAlert.toggle()
                } label: {
                    Text("Accept")
                }

            }

    }
}

struct CreateUserView_Previews: PreviewProvider {
    static var previews: some View {
        CreateUserView()
            .environmentObject(ModuleDependencies().usersViewModel())
    }
}
