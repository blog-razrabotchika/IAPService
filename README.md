# IAPService
Usage:

Add `IAPProduct.swift` and `IAPService.swift` to project directory

Change IAP identifers in `IAPProduct.swift` and add them to `func getProducts()` in `IAPService.swift`

Add these lines to your tableview

`import StoreKit`

`var products = [SKProduct]()`

```swift
     override func viewDidLoad() {
        super.viewDidLoad()
        subscribeToNotifications()
        loadAllProducts()
    }

    func subscribeToNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableData), name: Notification.Name("reloadAdTable"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.showErrorAllert), name: Notification.Name("restoreError"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.showSuccessAllert), name: Notification.Name("restoreSuccess"), object: nil)
    }
    
    @objc func reloadTableData(_ notification: Notification) {
        products = IAPService.shared.products
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
     func loadAllProducts() {
        IAPService.shared.getProducts()
    }
    
     @objc func restore() {
        IAPService.shared.restorePurchases()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let product = self.products[indexPath.row]
                
        cell.textLabel?.text = product.localizedTitle
        
        cell.detailTextLabel?.text = "\(product.price)"
        
           return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let product = products[indexPath.row]
        self.purchaseAtIndex(product: product)
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
     func purchaseAtIndex(product: SKProduct) {
        IAPService.shared.purchase(product: product)
    }
    
    @objc func showErrorAllert() {
        self.showAlert(title: "Error!", message: "Nothing to restore")
    }
    
    @objc func showSuccessAllert() {
        self.showAlert(title: "Success!", message: "IAP's successfully restored.")
    }
    
   func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title,
                                                    message: message,
                                                    preferredStyle: .alert)

            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)

            self.present(alertController, animated: true, completion: nil)
        }
    }
