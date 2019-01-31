//
//  GFWalletContentsService.swift
//  Genfare
//
//  Created by vishnu on 29/01/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Foundation
import Alamofire
import CoreData

class GFWalletContentsService {
    
    var walletID:NSNumber?
    
    init(walletID:NSNumber) {
        self.walletID = walletID
    }
    
    func headers() -> HTTPHeaders {
        var headers = GFEndpoint.commonHeaders
        let token:String = KeychainWrapper.standard.string(forKey: Constants.KeyChain.SecretKey)!
        headers["Authorization"] = String(format: "bearer %@", token)
        
        return headers
    }
    
    func parameters() -> [String:String] {
        return [:]
    }
    
    func getWalletContents(completionHandler:@escaping (_ success:Bool?,_ error:Any?) -> Void) {
        
        let endpoint = GFEndpoint.WalletContents(walledId: walletID!)
        
        Alamofire.request(endpoint.url, method: endpoint.method, parameters: parameters(), encoding: URLEncoding.default, headers: headers())
            .responseJSON { response in
                switch response.result {
                case .success(let JSON):
                    print(JSON)
                    completionHandler(true,nil)
                case .failure(let error):
                    print("Request failed with error: \(error)")
                    completionHandler(false,error)
                }
        }
    }
    
    func saveWalletContents(data:[String:Any]) {
        let managedContext = GFDataService.context
        let wallet = NSEntityDescription.entity(forEntityName: "Wallet", in: managedContext)
        let userObj:Wallet = NSManagedObject(entity: wallet!, insertInto: managedContext) as! Wallet
    }
    
}