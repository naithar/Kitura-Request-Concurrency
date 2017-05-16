//
//  KituraRequest+DispatchQueue.swift
//  KituraRequestConcurrency
//
//  Created by Sergey Minakov on 16.05.17.
//
//

import Dispatch

public extension DispatchQueue {
    
    public static let request = DispatchQueue(label: "kitura.request.concurrency.queue",
                                              attributes: [.concurrent])
}
