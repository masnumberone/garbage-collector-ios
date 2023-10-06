//
//  MockNetworkService.swift
//  Summer-practice
//
//  Created by work on 25.09.2023.
//

import Foundation

class MockNetworkService: NetworkServiceProtocol {
    func classifyBin(in image: BinPhoto, completion: @escaping (Result<[Bin], Error>) -> Void) {
        let dataString = getRandomResponce()
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
    }

    func setServerUrl(_: URL) {
        return
    }

    private func getRandomResponce() -> String {
        let maxIndex = MockNetworkService.responces.count - 1
        let randomIndex = Int.random(in: 0...maxIndex)

        return MockNetworkService.responces[randomIndex]
    }

    static let responces = [
        """
        [[587, 283, 730, 442, 'undefined', 0.91, 0.86],
        [277, 248, 420, 429, 'full', 0.89, 0.84],
        [946, 279, 1070, 435, 'full', 0.87, 0.96],
        [830, 279, 953, 435, 'halfempty', 0.78, 0.96],
        [414, 221, 570, 432, 'empty', 0.7, 0.76],
        [720, 270, 838, 437, 'empty', 0.46, 0.94],
        [138, 217, 291, 419, 'undefined', 0.32, 0.93]]
        """,
        """
        [[587, 283, 730, 442, 'undefined', 0.91, 0.86],
        [138, 217, 291, 419, 'undefined', 0.32, 0.93]]
        """,
        """
        [[587, 283, 730, 442, 'undefined', 0.91, 0.86],
        [277, 248, 420, 429, 'full', 0.89, 0.84],
        [946, 800, 1070, 950, 'full', 0.87, 0.96]]
        """,
        """
        [[946, 279, 1070, 435, 'full', 0.87, 0.96],
        [830, 279, 953, 435, 'halfempty', 0.78, 0.96],
        [414, 221, 570, 432, 'empty', 0.7, 0.76],
        [720, 270, 838, 437, 'empty', 0.46, 0.94],
        [138, 217, 291, 419, 'undefined', 0.32, 0.93]]
        """,
        """
        [[30, 30, 990, 990, 'full', 0.78, 0.96]]
        """,
        """
        [[830, 279, 953, 435, 'halfempty', 0.78, 0.96]]
        """
    ]
}
