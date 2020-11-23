//
//  ImportVentaArticulo.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 03/10/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//

import Foundation
import BLServerManager

extension ImportDatabase {
    class VentaArticulo {
        
        struct OldArticulo: Decodable {
            var childID : String
            var descripcionProducto : String
            var childIDSocio : String
            var childIDProducto : String
            var fechaCreacion : String
            var esAnulado : Bool
            var precioCompra : Double?
            var precioVenta : Double
            var childIDDescuento : String?
            var cantidadVendida : Int
        }
        
        static private func getVentasArticulos() -> [SellModel.Register]? {
            guard let json = ImportDatabase.loadBodyLife() else {
                return nil
            }
            
            guard let venta = json["venta"] as? [String : Any] else {
                return nil
            }
            
            guard let registers = venta["articulo"] as? [String : Any] else {
                return nil
            }
            
            var list = [[String : Any]]()
            
            for (_, value) in registers {
                guard let fechas = value as? [String : Any] else {
                    return nil
                }
                for (_, value1) in fechas {
                    guard let register = value1 as? [String: Any] else {
                        break
                    }
                    list.append(register)
                }
                
            }
            
            guard let data = try? JSONSerialization.data(withJSONObject: list, options: []) else {
                return nil
            }
            guard let oldRegisters = try? JSONDecoder().decode([ImportDatabase.VentaArticulo.OldArticulo].self, from: data) else {
                print("could not decode")
                return nil
            }
            
            var result = [SellModel.Register]()
            for i in oldRegisters {
                let createdAt = i.fechaCreacion.toDate(formato: "dd-MM-yyyy HH:mm:ss")?.timeIntervalSince1970 ?? Date().timeIntervalSince1970
                  
                let _id = ImportDatabase.codeUID(i.childID)
                let customerId = ImportDatabase.codeUID(i.childIDSocio)
                let dicountID = ImportDatabase.codeUID(i.childIDDescuento ?? "")
                let article = ImportDatabase.codeUID(i.childIDProducto)

                let newRegister = SellModel.Register(_id: _id,
                                                        customer: customerId,
                                                        discount: dicountID == "000000000000000000000000" ? nil : dicountID,
                                                        activity: nil,
                                                        article: article,
                                                        period: nil,
                                                        timestamp: createdAt,
                                                        fromDate: nil,
                                                        toDate: nil,
                                                        quantity: i.cantidadVendida,
                                                        isEnabled: !i.esAnulado,
                                                        productCategory: ProductCategory.article.rawValue,
                                                        price: i.precioVenta,
                                                        priceList: i.precioVenta,
                                                        priceCost: i.precioCompra,
                                                        description: i.descripcionProducto)
                
                result.append(newRegister)
            }
            return result
        }
        
        static private func encodeRegister(_ register: SellModel.Register) -> [String : Any] {
            let data = try? JSONEncoder().encode(register)
            let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
            return json!
        }
        
        static func MigrateToMongoDB() {
            guard let articulosVendidos = ImportDatabase.VentaArticulo.getVentasArticulos() else {
                return
            }
            var notAdded = 0
            for (x,articulo) in articulosVendidos.enumerated() {
                let semasphore = DispatchSemaphore(value: 0)
                
                let body = ImportDatabase.VentaArticulo.encodeRegister(articulo)
                let endpoint = Endpoint.Create(to: .Sell(.Save(body: body)))
                BLServerManager.ApiCall(endpoint: endpoint) { (data) in
                    semasphore.signal()
                } fail: { (error) in
                    print("no se guardo \(articulo.description) error")
                    notAdded += 1
                    print("not added \(notAdded)")
                    semasphore.signal()
                }
                _ = semasphore.wait(timeout: .distantFuture)
                print("\(x + 1)/\(articulosVendidos.count)")
            }
            print("not added \(notAdded)")
        }
    }
}
