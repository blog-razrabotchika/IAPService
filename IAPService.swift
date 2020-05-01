import Foundation
import StoreKit

class IAPService: NSObject {
    
    private override init() {}
    static let shared = IAPService()
    
    public var products = [SKProduct]() {
        didSet {
            self.postReloadNotification()
        }
    }
    
    let paymentQueue = SKPaymentQueue.default()
    
    func postErrorNotification() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "restoreError"), object: self)
        return
    }
    
    func postRestoredNotification() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "restoreSuccess"), object: self)
        return
    }
        
    func postReloadNotification() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadAdTable"), object: self)
    }
    
    func getProducts() {
        let products: Set<String> = [IAPProduct.appAdd.description]
    
        let request = SKProductsRequest(productIdentifiers: products)
        request.delegate = self
        request.start()
        paymentQueue.add(self)
    }
    
    func purchase(product: SKProduct) {
        guard let productToPurchase = products.filter({ $0.productIdentifier == product.productIdentifier }).first else { return }
        let payment = SKPayment(product: productToPurchase)
        paymentQueue.add(payment)
    }
    
    func restorePurchases() {
        print("Restoring purchases")
        paymentQueue.add(self)
        paymentQueue.restoreCompletedTransactions()
    }
}

extension IAPService: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.products = response.products
        for profuct in response.products {
            print(profuct.localizedTitle, profuct.price)
        }
    }
}


extension IAPService: SKPaymentTransactionObserver {
    
    func saveProduct(product: String) {
        UserDefaults.standard.set(true, forKey: product)
        print("Saved: ", product)
        self.postReloadNotification()
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            print(transaction.transactionState.status(), transaction.payment.productIdentifier)
            switch transaction.transactionState {
            case .purchasing: break
            case .restored:
                self.saveProduct(product: transaction.payment.productIdentifier)
                queue.finishTransaction(transaction)
            case .purchased:
                self.saveProduct(product: transaction.payment.productIdentifier)
                queue.finishTransaction(transaction)
            case .failed:
                self.postErrorNotification()
                queue.finishTransaction(transaction)
            default: break
            }
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        if queue.transactions.count == 0 {
            self.postErrorNotification()
        } else {
            for transaction in queue.transactions {
                self.saveProduct(product: transaction.payment.productIdentifier)
            }
            self.postRestoredNotification()
        }
    }
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        print(error.localizedDescription)
        if queue.transactions.count == 0 {
            self.postErrorNotification()
        }
    }
}


extension SKPaymentTransactionState {
    func status() -> String {
        switch self {
        case .deferred: return "deferred"
        case .failed: return "failed"
        case .purchased: return "purchased"
        case .purchasing: return "purchasing"
        case .restored: return "restored"
        @unknown default: return "default"
        }
    }
}
