//
//  importArticle.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 27/09/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//

import Foundation
import BLServerManager

extension ImportDatabase {
    class Article {
        static private func getArticles() -> [ArticleModel.NewRegister]? {
            guard let json = ImportDatabase.loadBodyLife() else {
                return nil
            }
            
            guard let conf = json["conf"] as? [String : Any] else {
                return nil
            }
            
            guard let carnet = conf["articulo"] as? [String : Any] else {
                return nil
            }
            
            guard let registers = carnet["producto"] as? [String : Any] else {
                return nil
            }
            
            var list = [[String : Any]]()
            
            for (_, value) in registers {
                guard let regs = value as? [String : Any] else {
                    return nil
                }
                list.append(regs)
               
            }
            
            guard let data = try? JSONSerialization.data(withJSONObject: list, options: []) else {
                return nil
            }
            guard let oldRegisters = try? JSONDecoder().decode([ArticleModel.Old].self, from: data) else {
                print("could not decode")
                return nil
            }
            
            var result = [ArticleModel.NewRegister]()
            for i in oldRegisters {
                let createdAt = i.fechaCreacion.toDate(formato: "dd-MM-yyyy HH:mm:ss")?.timeIntervalSince1970 ?? Date().timeIntervalSince1970
                let _id = ImportDatabase.codeUID(i.childID)
            
                let newRegister = ArticleModel.NewRegister(_id: _id,
                                                           description: i.descripcion,
                                                           isEnabled: !i.esOculto,
                                                           timestamp: createdAt,
                                                           price: i.precioVenta,
                                                           priceCost: i.precioCompra,
                                                           stock: 0,
                                                           minStock: 0,
                                                           maxStock: 0)
                
                result.append(newRegister)
            }
            return result
        }
        
        static private func encodeRegister(_ register: ArticleModel.NewRegister) -> [String : Any] {
            let data = try? JSONEncoder().encode(register)
            let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
            return json!
        }
        
        static func MigrateToMongoDB() {
            guard let articles = ImportDatabase.Article.getArticles() else {
                return
            }
            let uid = UserSaved.GetUID()
            let place = "product:article"
            var notAdded = 0
            for (x,article) in articles.enumerated() {
                let semasphore = DispatchSemaphore(value: 0)
                
                let body = ImportDatabase.Article.encodeRegister(article)
                let path = "/users:\(uid):\(place):\(article._id!)"
                
                let endpoint = Endpoint.Create(to: .Firebase(.Save(path: path, body: body)))
                BLServerManager.ApiCall(endpoint: endpoint) { (data) in
                    semasphore.signal()
                } fail: { (error) in
                    print("no se guardo \(article.description) error")
                    notAdded += 1
                    print("not added \(notAdded)")
                    semasphore.signal()
                }

                _ = semasphore.wait(timeout: .distantFuture)
                print("\(x + 1)/\(articles.count)")
            }
            print("not added \(notAdded)")
        }
    }
 
}

