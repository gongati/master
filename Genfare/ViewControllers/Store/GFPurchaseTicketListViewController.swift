//
//  GFPurchaseTicketListViewController.swift
//  Genfare
//
//  Created by omniwyse on 30/01/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import UIKit

class GFPurchaseTicketListViewController:GFBaseViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet var ProductsTableView: UITableView!
    var quantityValue = 0
    
    @IBOutlet var ContinueButton: GFMenuButton! //continueButton.
    @IBOutlet var MailLabel: UILabel!
    @IBOutlet var PayAsYouGoLabel: UILabel!
   @IBOutlet var DollarSymbolLabel: UILabel!
  @IBOutlet var PayAsYouGoTextField: UITextField!
    var products:Array<Product> =  GFFetchProductsService.getProducts()
    var productsListArray = [[String:Any]]()
     var productsListArrayPayAsYouGo = [AnyObject]()
    var totalProdcutArray = [AnyObject]()
    var fare = 0.0
    override func viewDidLoad() {
        super.viewDidLoad()
       targetMethod()
        
        var payAsYouGoText =  returnStoredValueWithActivation()
        for i in payAsYouGoText{
            self.PayAsYouGoLabel.text = i.productDescription
        }
        self.ProductsTableView.reloadData()
        // Do any additional setup after loading the view.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  productsListArray.count//products.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 150.0;
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ProductsTableView.dequeueReusableCell(withIdentifier: "PurchaseTicketTableViewCell", for: indexPath) as! PurchaseTicketTableViewCell
        
        print("Obj is:\(productsListArray[indexPath.row])")
        let prodObj = productsListArray[indexPath.row]
        
        if let riderText =  prodObj["productDescription"] as? String{
            cell.RiderName.text = riderText
            cell.RiderTypeDesc.text = riderText
        }
        cell.PlusButton.tag = indexPath.row
        cell.MinusButton.tag = indexPath.row
        cell.MinusButton.addTarget(self, action: #selector(minusbuttonCliked(sender:)), for: .touchUpInside)
        cell.PlusButton.addTarget(self, action: #selector(plusbuttonClicked(sender:)), for: .touchUpInside)
        let ticketCount   = prodObj["ticket_count"] as! Int
        cell.TicketCount.text = String(ticketCount)
        if let fare = prodObj["price"] as? String{
            cell.TicketAmount.text = String(format: "Fare $%@.00",fare)
        }
       
        if let individualFare = prodObj["total_ticket_fare"] as? Float{
            cell.TotalTicketFare.text = String(describing: individualFare)
        }
        
        return cell
    }

    
    func targetMethod(){
       
        if products.count > 0{
         var  filteredProdcutArray = returnStoredValueProducts()
            print(filteredProdcutArray)
        for i in filteredProdcutArray{
            var dict = [String:Any]()
               // var payasyougo = i["ticketTypeDescription"] as? String

                dict["productDescription"] = i.productDescription
                dict["offeringId"] = i.offeringId
                dict["ticketId"] = i.ticketId
                dict["price"] = i.price
                dict["ticketTypeDescription"] = i.ticketTypeDescription
                dict["ticket_count"] = quantityValue
                dict["total_ticket_fare"] = fare
                self.productsListArray.append(dict)

            }
            print(productsListArray)
            
        }
        
    }
    func payasyougo(){
        if products.count > 0 {
            productsListArrayPayAsYouGo.removeAll()
            var filteredProductArrayPayAsYouGo  = returnStoredValueWithActivation()
            print(filteredProductArrayPayAsYouGo)
            for i in filteredProductArrayPayAsYouGo{
                if(!(self.PayAsYouGoTextField.text?.isEmpty)!){
              //  if(self.PayAsYouGoTextField.text.length>0){
                var dict: [AnyHashable : Any] = [:]
                dict["productDescription"] = i.productDescription
                dict["offeringId"] = i.offeringId
                dict["ticketId"] = i.ticketId
                dict["price"] = i.price
                dict["ticketTypeDescription"] = i.ticketTypeDescription
                dict["ticket_count"] = 0
                dict["total_ticket_fare"] = self.PayAsYouGoTextField.text
                productsListArrayPayAsYouGo.append(dict as AnyObject)
            }
            }
            print(productsListArrayPayAsYouGo)

        }

    }
    func dictForPayAsYouGo() {
        var payasyougovalue = self.PayAsYouGoTextField.text
       // PayAsYouGoTextField.delegate = self as! UITextFieldDelegate
        UserDefaults.standard.set(payasyougovalue, forKey: "payasyougoamount")
    }
//
    func returnStoredValueWithActivation() -> [Product]{
        var arrStoredProds = [Product]()
        for prod in products{
            if let objProd = prod as? Product{
                if let ticetDesc = objProd.ticketTypeDescription, let active = objProd.isActivationOnly{
                    if ticetDesc == "Stored Value" && active == 0 {
                        arrStoredProds.append(objProd)
                    }
                }
            }
        }
        return arrStoredProds
    }
    func returnStoredValueProducts() -> [Product]{
       var arrStoredProds = [Product]()
        for prod in products{
            if let objProd = prod as? Product{
                if let ticetDesc = objProd.ticketTypeDescription{
                    if ticetDesc != "Stored Value"{
                        arrStoredProds.append(objProd)
                    }
                }
            }
        }
        return arrStoredProds
    }
    @objc func minusbuttonCliked(sender: GFMenuButton){
        if let dictObj = self.productsListArray[sender.tag] as? AnyObject{
            if let convertDict = dictObj as? Dictionary<String, Any>{
                quantityValue = convertDict["ticket_count"] as! Int
                  if(quantityValue>=1){
             //   if let count = convertDict["ticket_count"] as? Int{
                    quantityValue = quantityValue - 1
                    
                }
                var price = convertDict["price"] as! String
                let fare =  Float(quantityValue) * Float(price)!
                var Newdict: [AnyHashable : Any] = [:]
                var temp = NSMutableDictionary(dictionary: Newdict);
                Newdict.merge(dict: convertDict)
                Newdict["ticket_count"] = quantityValue
                  Newdict["total_ticket_fare"] = fare
                productsListArray[sender.tag] = Newdict as! [String : Any]
                
            
            }
        }
         self.ProductsTableView.reloadData()
        
    }
    @objc func plusbuttonClicked(sender: GFMenuButton){
       
        if let dictObj = self.productsListArray[sender.tag] as? AnyObject{
            if let convertDict = dictObj as? Dictionary<String, Any>{
              
                if let count = convertDict["ticket_count"] as? Int{
                    quantityValue = count + 1
                    
                }
                var price = convertDict["price"] as! String
                let fare =  Float(quantityValue) * Float(price)!
                var Newdict: [AnyHashable : Any] = [:]
                var temp = NSMutableDictionary(dictionary: Newdict);
                Newdict.merge(dict: convertDict)
                  Newdict["ticket_count"] = quantityValue
                  Newdict["total_ticket_fare"] = fare
                productsListArray[sender.tag] = Newdict as! [String : Any]
                }
            }
          
        
          self.ProductsTableView.reloadData()
//        if let count = dictObj["ticket_count"] as? Int{
//            self.quantityValue = count + 1
//
//        }
      
    }
    func showTotalAmount(){
        
    }
    func purchsestory(){
        if let navController = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "GFTicketDetailsViewController") as? GFTicketDetailsViewController {
            if let navigator = navigationController {
                navigator.pushViewController(navController, animated: false)
            }
        }
    }
    
    @IBAction func firstPageContinueButtonClicked(_ sender: GFMenuButton) {
        var seletedArray = [[String:Any]]()
        payasyougo()
        dictForPayAsYouGo()
       var  totalAmount = 0
        for j in 0..<productsListArray.count {
            var count = productsListArray[j]["ticket_count"] as? Int
            if !(count == 0) {
                seletedArray.append(productsListArray[j] as! [String : Any])
                totalAmount = totalAmount + ((productsListArray[j]["total_ticket_fare"] as? NSNumber)?.intValue)! ?? 0
            }
        }
        
      var payAsYouGoAmountValue =   UserDefaults.standard.integer(forKey: "payasyougoamount")
        totalAmount = totalAmount + payAsYouGoAmountValue;

      var seletedArraypayasyougo = [[String:Any]]()
        for j in 0..<productsListArrayPayAsYouGo.count {

            seletedArraypayasyougo.append(productsListArrayPayAsYouGo[j] as! [String : Any])
        }
        print(seletedArray)
        print(seletedArraypayasyougo)
       // purchsestory()
      var newarray = seletedArraypayasyougo + seletedArray
        let navController = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "GFTicketDetailsViewController") as? GFTicketDetailsViewController
        navController!.seletedProducts = newarray
        navigationController?.pushViewController(navController!, animated: true)
       // ticketview.seletedProducts = newArray
//       var totalAmount = 0
//        var selectedArray = [AnyObject]()
//        for i in productsListArray{
//             let prodObj = i
//            if let checkArray = prodObj["ticket_count"] as? Int{
//                if checkArray != 0{
//                    selectedArray = prodObj.
//                }
//            }
//        }
//
   }
}
extension Dictionary {
    mutating func merge(dict: [Key: Value]){
        for (k, v) in dict {
            updateValue(v, forKey: k)
        }
    }
}
