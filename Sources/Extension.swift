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
        -> Task<RequestResult<T>> {
            let task = Task<RequestResult<T>>(in: queue) { task in
                self.response { request, response, data, error in
                    guard error == nil, let data = data else {
                        task.throw(error ?? RequestError.unexpectedResponse)
                        return
                    }
                    
                    do {
                        let value = try T.convert(data)
                        let result = RequestResult(request: request, response: response, value: value)
                        task.send(result)
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
        -> Task<RequestResult<T>> {
            let newTask = Task<RequestResult<T>>(in: queue)
            
            self
                .done(in: queue) { request in
                    request.response { request, response, data, error in
                        
                        guard error == nil, let data = data else {
                            newTask.throw(error ?? RequestError.unexpectedResponse)
                            return
                        }
                        
                        do {
                            let value = try T.convert(data)
                            let result = RequestResult(request: request, response: response, value: value)
                            newTask.send(result)
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

public extension Task where Element: RequestResultable {
    
    typealias RequestType = Element.Element
    
    public func validate(in queue: DispatchQueue = .request,
                         _ validation: ((RequestResult<RequestType>) throws -> Bool)? = { result in return (result.response?.status ?? 0) >= 200 && (result.response?.status ?? 0) <= 300 }) -> Task<RequestType> {
        let task = Task<RequestType>()
        
        
        func set(with value: RequestConvertible) {
            if let value = value as? RequestType {
                task.send(value)
            } else {
                task.throw(RequestError.unexpectedResponse)
            }
        }
        
        self
            .done { response in
                guard let response = response as? RequestResult<RequestType> else {
                    task.throw(RequestError.invalid)
                    return
                }
                
                guard let validation = validation else {
                    set(with: response.value)
                    return
                }
                
                do {
                    if try validation(response) {
                        set(with: response.value)
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
