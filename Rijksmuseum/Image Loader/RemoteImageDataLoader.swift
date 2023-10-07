//
//  RemoteImageDataLoader.swift
//  Rijksmuseum
//
//  Created by Andrei on 07/10/2023.
//

import Foundation

final class RemoteImageDataLoader: ImageDataLoader {
    let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    struct Task: ImageDataLoaderTask {
        let task: URLSessionDataTask
        
        fileprivate init(task: URLSessionDataTask) {
            self.task = task
        }
        
        func cancel() {
            task.cancel()
        }
    }
    
    enum Error: Swift.Error {
        case noData
    }
    
    func loadImageData(from url: URL, completion: @escaping (ImageDataLoader.Result) -> Void) -> ImageDataLoaderTask {
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 10.0)
        let task = session.dataTask(with: request) { data, response, error in
            if let error {
                completion(.failure(error))
            }
            guard let data else {
                return completion(.failure(Error.noData))
            }
            return completion(.success(data))
        }
        task.resume()
        
        return Task(task: task)
    }
}
