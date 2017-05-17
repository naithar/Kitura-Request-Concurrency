@_exported import KituraRequest
@_exported import Concurrency

public extension KituraRequest {
    
    public static func start(in queue: DispatchQueue = .request,
                             _ method: Request.Method,
                             _ URL: String,
                             parameters: Request.Parameters? = nil,
                             encoding: Encoding = URLEncoding.default,
                             headers: [String: String]? = nil) -> Task<Request> {
        return Task<Request>(in: queue,
                             value: self
                                .request(method, URL,
                                         parameters: parameters,
                                         encoding: encoding,
                                         headers: headers))
    }
}

public extension Request {
    
    public func response<T: RequestConvertible>(in queue: DispatchQueue = .request, with: T.Type) -> Task<T> {
        let task = Task<T>(in: queue) { task in
            self.response { request, response, data, error in
                guard error == nil, let data = data else {
                    task.throw(error ?? RequestError.unexpectedResponse)
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


public extension Task where Element == Request {
    
    public func response<T: RequestConvertible>(in queue: DispatchQueue = .request, with: T.Type) -> Task<T> {
        let newTask = Task<T>(in: queue)
        
        self
            .done(in: queue) { request in
                request.response { request, response, data, error in
                    guard error == nil, let data = data else {
                        newTask.throw(error ?? RequestError.unexpectedResponse)
                        return
                    }
                    
                    do {
                        let value = try T.convert(data)
                        newTask.send(value)
                    } catch {
                        newTask.throw(error)
                    }
                    
                }
            }.catch(in: queue) {
                newTask.throw($0)
        }
        
        return newTask
    }
}
