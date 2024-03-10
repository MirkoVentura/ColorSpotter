//
//  ApiService.swift
//  ColorSpotter
//
//  Created by Mirko Ventura on 10/03/24.
//

import Foundation
import Combine

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case requestFailed
    // Altri possibili errori, come errori di parsing, possono essere aggiunti qui
}

struct APIService {
    func fetchData(from url: URL) -> AnyPublisher<Data, Error> {
        return URLSession.shared.dataTaskPublisher(for: url)
            .mapError { error in
                APIError.requestFailed
            }
            .map { $0.data }
            .eraseToAnyPublisher()
    }
}

