@_exported import KituraRequest
@_exported import Concurrency
import KituraNet

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
    
    public func response<T: RequestConvertible>(in queue: DispatchQueue = .request, with: T.Type)
        -> Task<(ClientRequest?, ClientResponse?, T)> {
            let task = Task<(ClientRequest?, ClientResponse?, T)>(in: queue) { task in
                self.response { request, response, data, error in
                    guard error == nil, let data = data else {
                        task.throw(error ?? RequestError.unexpectedResponse)
                        return
                    }
                    
                    do {
                        let value = try T.convert(data)
                        task.send((request, response, value))
                    } catch {
                        task.throw(error)
                    }
                    
                }
            }
            
            return task
    }
}


public extension Task where Element == Request {
    
    public func response<T: RequestConvertible>(in queue: DispatchQueue = .request, with: T.Type)
        -> Task<(ClientRequest?, ClientResponse?, T)> {
            let newTask = Task<(ClientRequest?, ClientResponse?, T)>(in: queue)
            
            self
                .done(in: queue) { request in
                    request.response { request, response, data, error in
                        
                        guard error == nil, let data = data else {
                            newTask.throw(error ?? RequestError.unexpectedResponse)
                            return
                        }
                        
                        do {
                            let value = try T.convert(data)
                            newTask.send((request, response, value))
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

public extension Task where Element == (ClientRequest?, ClientResponse?, T: RequestConvertible) {
    
    typealias RequestType = T
    public func validate(in queue: DispatchQueue = .request,
                         action: ((ClientRequest?, ClientResponse?) throws -> Bool)? = nil) -> Task<RequestType> {
        let task = Task<RequestType>()
        
        func set(with value: RequestConvertible) {
            if let value = value as? RequestType {
                task.send(value)
            } else {
                task.throw(RequestError.unexpectedResponse)
            }
        }
        
        self
            .done { (request, response, value) in
                guard let action = action else {
                    set(with: value)
                    return
                }
                
                do {
                    if try action(request, response) {
                        set(with: value)
                    } else {
                        task.throw(RequestError.invalid)
                    }
                } catch {
                    task.throw(error)
                }
            }.catch { task.throw($0) }
        
        return task
    }
}
