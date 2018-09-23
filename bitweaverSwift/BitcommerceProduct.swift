//  Converted to Swift 4 by Swiftify v4.1.6809 - https://objectivec2swift.com/
//
//  BitcommerceProduct.swift
//  PBPro API Demo
//
//  Created by Christian Fowler on 6/27/12.
//  Copyright (c) 2012 Viovio.com. All rights reserved.
//

class BitcommerceProduct: BitweaverRestObject {
    // REST properties
    @objc dynamic var productId: NSNumber?    /* Content ID created by remote system */
    @objc dynamic var productTypeName = ""
    @objc dynamic var productTypeClass = ""
    @objc dynamic var productDefaultImage = ""
    var enabled: [Bool] = []
    var images: [String:String] = [:]

    convenience init(fromHash hash: [String : String]) {
        self.init()
        load(fromRemoteProperties: hash)
    }

    override func getAllPropertyMappings() -> [String : String]? {
        var mappings = [
            "product_id" : "productId",
            "product_default_image" : "productDefaultImage"
        ]

        for (k, v) in super.getAllPropertyMappings()! { mappings[k] = v }
        return mappings
    }

    override func getSendablePropertyMappings() -> [String : String]? {
        var mappings = [
            "product_type_class" : "productTypeClass"
        ]
        for (k, v) in super.getSendablePropertyMappings()! { mappings[k] = v }
        return mappings
    }

    func isValid() -> Bool {
        return productId != nil
    }
    
    static func getList( completion: @escaping (Dictionary<String, BitcommerceProduct>) -> Void ) {
        if let operation = AFJSONRequestOperation(request: gBitweaverHTTPClient.request(withPath: "products/list")! as URLRequest, success: { request, response, JSON in
            var productList = Dictionary<String, BitcommerceProduct>()
            if (JSON is [String : Any]) {
                for (productId,hash) in JSON as! [String : [String:Any]] {
                    var className = "BitcommerceProduct"
                    if hash["products_class"] != nil {
                        className = hash["products_class"] as! String
                    }
                    
                    switch className {
                    //case "ArtDesignerProduct":
                    //case "PrintSetDesignerProduct":
                    //case "DigitalProduct":
                    //case "BookMachineProduct":
                    //case "PhotoPrintProduct":
                    //case "ApiDesignerProduct":
                    //case "BookDesignerProduct":
                    //case "ApiPdfProduct":
                    //case "GiftDesignerProduct":
                    //case "TextBookPdfProduct":
                    //case "PrintSetPdfProduct":
                    //case "CalendarPdfProduct":
                    //case "CalendarDesignerProduct":
                    //case "CardDesignerProduct":
                    //case "TextDesignerProduct":
                    //case "AlbumPdfProduct":
                    //case "AlbumDesignerProduct":
                    case "PdfBookProduct":
                        //productClass = NSClassFromString(className) as! PdfBookProduct
                        productList[productId] = PdfBookProduct.init(fromHash: hash as! [String : String])
                    default:
                        productList[productId] = BitcommerceProduct.init(fromHash: hash as! [String : String])
                    }

                }
            }
            completion( productList )
            // Send a notification event user has just logged in.
            NotificationCenter.default.post(name: NSNotification.Name("ProductListLoaded"), object: self)
        }, failure: { request, response, error, JSON in
        }) {
            OperationQueue().addOperation(operation)
        }
    }
}
