//
//  UploadPhotoAPI.swift
//  ddgLoginTestApp
//
//  Created by David Diego Gomez on 23/06/2022.
//

import Cocoa
import BLServerManager

class UploadPhotoAPI {

    static func uploadPhoto(path: String, imageData: Data, nombre: String, tipo: String, completion:@escaping ([String : Any]?, ServerError?) -> Void ) {
        let formFields: [String: String] = [:]
        
        let session = URLSession(configuration: .default)
        let stringUrl = "\(BLServerManager.baseUrl.rawValue)/v1/uploadImage/\(path)"
        guard let url = URL(string: stringUrl) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        
        
        //MARK: Multipart
        let boundary = "Boundary-\(UUID().uuidString)"
        
        //headers
        request.addValue("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiJJZnkyZjJ6dFEzZm5CNVZzZnJFNW1WcEhpdTQzIiwiaWF0IjoxNjU2MDAyODc5LCJleHAiOjE2NTYwODkyNzl9.mk_Lnpe4yP8Ov_00g4byOJ1TlWOe3FekpD8SAyMfuio", forHTTPHeaderField: "x-access-token")
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        //MARK: Body
        
        let httpBody = NSMutableData()
        
        for (key, value) in formFields {
            httpBody.appendString(convertFormField(named: key, value: value, using: boundary))
        }
        
        httpBody.append(convertFileData(fieldName: "image",
                                        fileName: "\(nombre).\(tipo)",
                                        mimeType: "image/jpeg",
                                        fileData: imageData,
                                        using: boundary))
        
        httpBody.appendString("--\(boundary)--")
        
        request.httpBody = httpBody as Data
        
        // task
        let dataTask = session.dataTask(with: request) { data, res, err in
            if err != nil {
                completion(nil, .error500)
                return
            }
            
            guard let data = data,
                  let response = res as? HTTPURLResponse else {
                print("some other error")
                return
            }
            let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            let status = response.statusCode
            guard (200...299).contains(status) else {
                completion(nil, .error500)
                return
            }
            
            completion(json, nil)
        }
        dataTask.resume()
        
    }
    
    static func convertFormField(named name: String, value: String, using boundary: String) -> String {
        var fieldString = "--\(boundary)\r\n"
        fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n"
        fieldString += "\r\n"
        fieldString += "\(value)\r\n"
        
        return fieldString
    }
    
    static func convertFileData(fieldName: String, fileName: String, mimeType: String, fileData: Data, using boundary: String) -> Data {
        let data = NSMutableData()
        
        data.appendString("--\(boundary)\r\n")
        data.appendString("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n")
        data.appendString("Content-Type: \(mimeType)\r\n\r\n")
        data.append(fileData)
        data.appendString("\r\n")
        
        return data as Data
    }
    
    
}

extension NSMutableData {
    func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}
