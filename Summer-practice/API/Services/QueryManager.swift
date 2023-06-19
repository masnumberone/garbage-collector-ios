//
//  QueryManager.swift
//  Summer-practice
//
//  Created by work on 14.06.2023.
//

import Foundation
import UIKit

class QueryManager {
    
    static let shared = QueryManager()
    static var baseUrl = URL(string: "http://172.20.10.3:8080")!        // wi-fi modem
//    let baseUrl = URL(string: "http://172.20.10.10:8080")!         // usb
    
    // MARK: - API methods
    
    func classifyBin(in image: BinPhoto, completion: @escaping (Result<[Bin], Error>) -> Void) {
        
        var request = URLRequest(url: URL(string: "/predictions/garbage_cont_classify", relativeTo: QueryManager.baseUrl)!)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let paramName = "data"
        var data = Data()
                
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\(paramName)\"; filename=\"\(Int64(Date().timeIntervalSince1970*1000)).png\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        data.append(image.data!)
        data.append(UIImage(data: image.data!)!.pngData()!)
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        print("did configure request")


        URLSession.shared.uploadTask(with: request, from: data) {  data, response, error in
            if let error = error {
                completion(.failure(error))
                print("error response")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, let data = data else {
                completion(.failure(NSError()))
                print("fail httpResponse")
                return
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                print(String(data: data, encoding: .utf8)!)
                
                let dataString = String(data: data, encoding: .utf8)!
                let stringArray = dataString
                    .filter {
                        !"[]".contains($0)
                    }
                    .components(separatedBy: ",\n")

                var bins: [Bin] = []
                for item in stringArray {
                    if let bin = Bin.decode(fromSting: item) {
                        bins.append(bin)
                    }
                }
                completion(.success(bins))
                
            case 500:
                print(String(data: data, encoding: .utf8) ?? "error code 500 response")
                completion(.failure(NSError()))
            default:
                print(String(data: data, encoding: .utf8) ?? "unidentified error response")
                completion(.failure(NSError()))
            }
            
        }.resume()
    }
    
}



