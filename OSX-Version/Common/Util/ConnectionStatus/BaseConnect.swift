//
//  BaseConnect.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 16/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Foundation


class BaseConnect {
    static internal var process : Process?
    static internal let pathEnDiscoServidor = "/usr/local/bin/package/BodyShaping/www"
      
    
    static internal func cerrarProcesoWWW() {
        let semaforoKillProcess = DispatchSemaphore(value: 0)
        
        //Primero cerramos algun proceso www que pudiera estar ejecutandose
        MLConsoleCommand.runProcess(name: "/usr/bin/killall", arguments: ["www"], success: { (process) in
            semaforoKillProcess.signal()
        }) { (error) in
            semaforoKillProcess.signal()
        }
        
        _ = semaforoKillProcess.wait(timeout: .distantFuture)
    }
    
   
    
    static internal func runServerStatus(url: String, success: @escaping () -> (), fail: @escaping () -> ()) {
        
        let request: NSMutableURLRequest = NSMutableURLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        var session = URLSession.shared
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 10
        sessionConfig.timeoutIntervalForResource = 15.0
        session = URLSession(configuration: sessionConfig)
        
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            
            guard error == nil else {
                fail()
                return
            }
            
            guard let data = data else {
                fail()
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String : String]
                
                if json["connection"] == "ok" {
                    success()
                } else {
                    fail()
                }
                
            } catch {
                fail()
            }
        })
        task.resume()
        
    }
    
    
}
