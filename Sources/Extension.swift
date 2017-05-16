@_exported import KituraRequest
@_exported import Concurrency
import Foundation
import Dispatch

extension DispatchQueue {
    
    static let request = DispatchQueue(label: "kitura.request.concurrency.queue",
                                       attributes: [.concurrent])
}

extension Request {
    
    enum Error: Swift.Error {
        
        case unexpectedResponse
    }
    
    func response<T: RequestConvertible>(with: T.Type) -> Task<T> {
        let task = Task<T>(on: .request) { task in
            self.response { request, response, data, error in
                guard error == nil, let data = data else {
                    task.throw(error ?? Error.unexpectedResponse)
                    return
                }
                
                do {
                    let value = try T.convert(data)
                    task.send(value)
                } catch {
                    task.throw(error)
                }
                
            }
        }
        
        return task
    }
}
