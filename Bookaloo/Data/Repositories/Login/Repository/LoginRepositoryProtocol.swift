//
//  LoginRepositoryProtocol.swift
//  Bookaloo
//
//  Created by Joyce Rosario Batista on 3/2/23.
//

import Foundation

protocol LoginRepositoryProtocol {
    func validate(_ user: User) async throws -> User
}
