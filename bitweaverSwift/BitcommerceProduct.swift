//  Converted to Swift 4 by Swiftify v4.1.6809 - https://objectivec2swift.com/
//
//  BitcommerceProduct.swift
//  PBPro API Demo
//
//  Created by Christian Fowler on 6/27/12.
//  Copyright (c) 2012 Viovio.com. All rights reserved.
//

import Cocoa
import Alamofire

class BitcommerceProduct: BitweaverRestObject {
    // REST properties
    @objc dynamic var productId: NSNumber?    /* Content ID created by remote system */
    @objc dynamic var productTypeName: String?
    @objc dynamic var productTypeClass: String = "BitcommerceProduct"
    @objc dynamic var productModel: String = ""
    @objc dynamic var productDefaultIcon: String = ""
    var enabled: [Bool] = []
    var images: [String: String] = [:]

    // Prevent multiple
    static var active: BitcommerceProduct? { return gBitProduct }

    override init() {
        super.init()
    }

    override func initProperties() {
        super.initProperties()
        contentTypeGuid = "bitproduct"
        productTypeClass = getRemoteTypeClass()
    }

    func getRemoteTypeClass() -> String {
        return NSStringFromClass(type(of: self))
    }

    convenience init(fromJson hash: [String: Any]) {
        self.init()
        load(fromJson: hash)
    }

    override func remoteUrl() -> String {
       return gBitSystem.apiBaseUri+"products/"+contentUuid.uuidString
    }

    override func getAllPropertyMappings() -> [String: String] {
        var mappings = [
            "product_id": "productId",
            "product_model": "productModel",
            "product_type_name": "productTypeName",
            "product_type_icon": "productDefaultIcon"
        ]

        for (k, v) in super.getAllPropertyMappings() { mappings[k] = v }
        return mappings
    }

    override func load(fromJson remoteHash: [String: Any]) {
        super.load(fromJson: remoteHash)
    }

    override func getSendablePropertyMappings() -> [String: String] {
        var mappings = [
            "product_type_class": "productTypeClass"
        ]
        for (k, v) in super.getSendablePropertyMappings() { mappings[k] = v }
        return mappings
    }

    func isValid() -> Bool {
        return productId != nil
    }

    func getEditViewController() -> BWViewController {
        return getViewController("Edit")
    }

    func getPreviewViewController() -> BWViewController {
        return getViewController("Preview")
    }

    private func getViewController(_ type: String) -> BWViewController {
        let controllerClass: String = productTypeClass+type+"ViewController"
        if let bundleName = Bundle.main.infoDictionary!["CFBundleName"] as? String,
           let ret: BitcommerceProductViewController.Type = NSClassFromString( bundleName + "." + controllerClass ) as? BitcommerceProductViewController.Type {
            return ret.init()
        } else {
            return BitcommerceProductViewController.init()
        }
    }

    func getTypeImageDefault() -> NSImage {
        return BWImage.init(named: "NSAdvanced")!
    }

    func getTypeImage() -> BWImage {
        var ret: BWImage?
        if let defaultImage = remoteHash["product_type_icon"] {
            let imageUrl = URL.init(fileURLWithPath: defaultImage)
            ret = NSImage.init(named: imageUrl.deletingPathExtension().lastPathComponent) ?? nil
        }
        return ret ?? getTypeImageDefault()
    }

    func newProduct(_ remoteHash: [String: Any] ) -> BitcommerceProduct? {
        // default is type of class invoked
        var classNames: [String] = [NSStringFromClass(type(of: self))]
        if let productClass = remoteHash["product_type_class"] as? String {
            // will attempt to create product of specific type listed
            classNames.insert(productClass, at: 0)
        }
        for className in classNames {
            if let newProduct = BitweaverRestObject.newObject( className, remoteHash ) as? BitcommerceProduct {
                return newProduct
            }
        }
        return nil
    }

    func getList( completion: @escaping ([String: BitcommerceProduct]) -> Void ) {
        loadLocal( completion: completion )
        loadRemote( completion: completion )
    }

    func loadLocal( completion: @escaping ([String: BitcommerceProduct]) -> Void ) {
        let fileManager = FileManager.default
        let resourceKeys: [URLResourceKey] = [.creationDateKey, .isDirectoryKey]
        let enumerator = FileManager.default.enumerator(at: localProjectsUrl!, includingPropertiesForKeys: resourceKeys,
                                                        options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants], errorHandler: { (url, error) -> Bool in
                                                            print("directoryEnumerator error at \(url): ", error)
                                                            return true
        })!

        var productList: [String: BitcommerceProduct] = [:]

        for case let fileURL as URL in enumerator {
            do {
                let resourceValues = try fileURL.resourceValues(forKeys: Set(resourceKeys))
                if resourceValues.isDirectory! {
                    let dirUuid = fileURL.lastPathComponent
                    let jsonUrl = fileURL.appendingPathComponent("content.json")
                    if fileManager.fileExists(atPath: jsonUrl.path) {
                        let data = try Data(contentsOf: jsonUrl, options: .mappedIfSafe)
                        let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                        if let remoteHash = jsonResult as? [String: String] {
                            if let newProduct = newProduct( remoteHash ) {
                                if let localUuid = UUID.init(uuidString: dirUuid) {
                                    newProduct.contentUuid = localUuid
                                }
                                productList[dirUuid] = newProduct
                                break
                            }
                        }
                    }
                }
            } catch {
                print(error)
            }
        }
        completion( productList )
        // Send a notification event user has just logged in.
        NotificationCenter.default.post(name: NSNotification.Name("ProductListLoaded"), object: self)
    }

    func loadRemote( completion: @escaping ([String: BitcommerceProduct]) -> Void ) {
        if BitweaverUser.active.isAuthenticated() {
            let headers = gBitSystem.httpHeaders()
            Alamofire.request(gBitSystem.apiBaseUri+"products/list",
                              method: .get,
                              parameters: nil,
                              encoding: URLEncoding.default,
                              headers: headers)
                .validate()
                .responseJSON { [weak self] response in
                    switch response.result {
                    case .success :
                        if let jsonList = response.result.value as? [String: [String: Any]] {
                            var productList = [String: BitcommerceProduct]()
                            for (_, remoteHash) in jsonList as [String: [String: Any]] {
                                if let newProduct = self?.newProduct( remoteHash ) {
                                    newProduct.cacheLocal()
                                    productList[newProduct.contentUuid.uuidString] = newProduct
                                }
                            }
                            completion( productList )
                        }
                        // Send a notification event user has just logged in.
                        NotificationCenter.default.post(name: NSNotification.Name("ProductListLoaded"), object: self)
                    case .failure :
                        //let errorMessage = gBitSystem.httpError( response:response, request:response.request )
                        //gBitSystem.log( errorMessage )
                        completion( [:] )
                    }
            }
        }
    }
}

var gBitProduct: BitcommerceProduct?
