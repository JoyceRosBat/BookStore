//
//  ShopViewModel.swift
//  Bookaloo
//
//  Created by Joyce Rosario Batista on 1/2/23.
//

import Foundation

enum ShopBookCase {
    case increment
    case decrement
}

enum PurchaseStatus: String, CaseIterable {
    case inProgress = "In progress"
    case delivered = "Delivered"
    case cancelled = "Cancelled"
}

final class ShopViewModel: ObservableBaseViewModel {
    let dependencies: ShopDependenciesResolver
    var shopUseCase: ShopUseCaseProtocol {
        dependencies.resolve()
    }
    
    @Published var shopBook: Bool = false
    
    @Published var booksToShop: [Int: Int] = Storage.shared.get(key: .cart, type: [Int: Int].self) ?? [:]
    @Published var booksOrdered: Int = 0
    @Published var bookSelected: Book?
    
    @Published var showRemoveBookAlert: Bool = false
    @Published var finishShopAlert: Bool = false
    @Published var shopCompleteAlert: Bool = false
    
    @Published var pendingOrder: Order?
    
    @Published var userOrders: [Order] = []
    @Published var ordersStatus: [PurchaseStatus] = [.inProgress, .delivered, .cancelled]
    @Published var inProgressList: [Order] = []
    @Published var deliveredList: [Order] = []
    @Published var cancelledList: [Order] = []
    
    var viewDidLoad: Bool = false
    
    init(dependencies: ShopDependenciesResolver) {
        self.dependencies = dependencies
    }
    
    func updateCart() {
        if !viewDidLoad {
            updateShop()
            viewDidLoad = true
        }
    }
    
    /// Creates the order and shop
    /// ```
    ///        viewModel.finishShop()
    /// ```
    func finishShop() {
        showLoading(true)
        Task {
            await MainActor.run { [weak self] in
                guard let self = self else { return }
                if let email = self.user?.email {
                    var order = Order(email: email)
                    order.order = []
                    self.booksToShop.forEach { (book, quantity) in
                        for _ in 0..<quantity {
                            order.order?.append(book)
                        }
                    }
                    Task {
                        do {
                            self.pendingOrder = try await self.shopUseCase.new(order)
                            self.booksToShop.removeAll()
                            self.booksOrdered = 0
                            Storage.shared.save(self.booksToShop, key: .cart)
                            showLoading(false)
                            shopCompleteAlert = true
                        } catch let error as NetworkError {
                            showNetworkError(error)
                        }
                    }
                } else {
                    showLoading(false)
                }
            }
        }
    }
    
    /// Adds a book to the cart prepared to shop
    /// ```
    ///        viewModel.addToCat(book)
    /// ```
    /// - Parameters:
    ///   - book: The book to add to cart
    func addToCart(_ book: Book) {
        updateBooksToShop(with: book.id)
        //        Task {
        //            await MainActor.run {
        //                shopBook = false
        //            }
        //        }
        //        shopBook = false
    }
    
    /// Removes a book from the cart
    /// ```
    ///        viewModel.removeFromCart(book)
    /// ```
    /// - Parameters:
    ///   - book: The book to remove from the cart
    func removeFromCart(_ book: Book) {
        updateBooksToShop(with: book.id, shopCase: .decrement)
    }
    
    /// Removes the book selected
    /// ```
    ///        viewModel.removeBookSelected()
    /// ```
    func removeBookSelected() {
        if let bookSelected {
            booksToShop.removeValue(forKey: bookSelected.id)
            updateShop()
            Storage.shared.save(booksToShop, key: .cart)
            self.bookSelected = nil
        }
    }
    
    /// Get the orders of a user
    /// ```
    ///        viewModel.getOrders()
    /// ```
    func getOrders() {
        showLoading(true)
        guard let email = user?.email else {
            showLoading(false)
            return
        }
        Task {
            await MainActor.run { [weak self] in
                guard let self = self else { return }
                Task {
                    do {
                        self.userOrders = try await shopUseCase.orders(of: email)
                        self.inProgressList = self.userOrders
                            .filter{ $0.status == .processing || $0.status == .sent || $0.status == .received }
                            .sorted(by: { $0.status?.rawValue ?? "" < $1.status?.rawValue ?? "" })
                            .sorted(by: { $0.date ?? .now < $1.date ?? .now })
                        self.deliveredList = self.userOrders.filter{ $0.status == .delivered }
                            .sorted(by: { $0.date ?? .now < $1.date ?? .now })
                        self.cancelledList = self.userOrders
                            .filter{ $0.status == .canceled || $0.status == .returned }
                            .sorted(by: { $0.status?.rawValue ?? "" < $1.status?.rawValue ?? "" })
                            .sorted(by: { $0.date ?? .now < $1.date ?? .now })
                        showLoading(false)
                    } catch let error as NetworkError {
                        showNetworkError(error)
                    }
                }
            }
        }
    }
}

private extension ShopViewModel {
    func updateShop() {
        booksOrdered = booksToShop.values.reduce(0, +)
    }
    
    func updateBooksToShop(with id: Int, shopCase: ShopBookCase = .increment) {
        if booksToShop.contains(where: { $0.key == id }) {
            var quantity = booksToShop.first(where: { $0.key == id })?.value ?? 0
            switch shopCase {
            case .increment:
                quantity += 1
            case .decrement:
                quantity -= 1
            }
            if quantity == 0 {
                booksToShop.removeValue(forKey: id)
            } else {
                booksToShop.updateValue(quantity, forKey: id)
            }
        } else {
            booksToShop[id] = 1
        }
        updateShop()
        Storage.shared.save(booksToShop, key: .cart)
    }
}

