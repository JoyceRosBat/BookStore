//
//  ShopUseCase.swift
//  Bookaloo
//
//  Created by Joyce Rosario Batista on 1/2/23.
//

import Foundation

protocol ShopUseCaseProtocol {
    func new(_ order: Order) async throws -> Order
    func check(by number: String) async throws -> Order
    func orders(of email: String) async throws -> [Order]
    func status(of orderId: String) async throws -> OrderStatus
    func modify(_ data: OrderModify) async throws
}

final class ShopUseCase: ShopUseCaseProtocol {
    private let repository: ShopRepositoryProtocol
    
    init(dependencies: ShopDependenciesResolver) {
        self.repository = dependencies.resolve()
    }
    
    /// Makes a new order to shop books
    /// ```
    ///        shopUseCase.new(order)
    /// ```
    /// - Parameters:
    ///   - order: Order with the list of books to shop
    func new(_ order: Order) async throws -> Order {
        try await repository.new(order)
    }
    
    /// With the number of order returns the order detail
    /// ```
    ///        shopUseCase.check(by: number)
    /// ```
    /// - Parameters:
    ///   - number: Number of the order to check
    func check(by number: String) async throws -> Order {
        try await repository.checkOrder(by: number)
    }
    
    /// Get all the orders of a user
    /// ```
    ///        shopUseCase.orders(of: email)
    /// ```
    /// - Parameters:
    ///   - email: Email of the user to get the orders
    func orders(of email: String) async throws -> [Order] {
        try await repository.getOrders(of: email)
    }
    
    /// Get the status of an order by its id
    /// ```
    ///        shopUseCase.status(of: orderId)
    /// ```
    /// - Parameters:
    ///   - orderId: Id number of the order to check th status
    func status(of orderId: String) async throws -> OrderStatus {
        try await repository.getStatus(of: orderId)
    }
    
    /// Modify the status of an order
    /// ```
    ///        shopUseCase.modify(data)
    /// ```
    /// - Parameters:
    ///   - data: Data to modify
    func modify(_ data: OrderModify) async throws {
        _ = try await repository.modify(data)
    }
}
