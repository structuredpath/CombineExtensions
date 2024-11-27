import CombineExtensions
import Combine
import XCTest

class FlatMapLatestTests: XCTestCase {
    
    func test() {
        var cancellables = Set<AnyCancellable>()
        
        let inner1 = PassthroughSubject<Int, Never>()
        let inner2 = PassthroughSubject<Int, Never>()
        
        let outer = CurrentValueSubject<AnyPublisher<Int, Never>, Never>(
            Empty<Int, Never>().eraseToAnyPublisher()
        )
        
        var completed = false
        var results = [Int]()
        
        outer
            .flatMapLatest { $0 }
            .sink { _ in
                completed = true
            } receiveValue: { pair in
                results.append(pair)
            }
            .store(in: &cancellables)
        
        XCTAssertTrue(results.isEmpty)
        
        inner1.send(0xA1)
        inner2.send(0xB1)
        
        outer.value = inner1.eraseToAnyPublisher()
        
        inner1.send(0xA2)
        inner2.send(0xB2)
        
        XCTAssertEqual(results, [0xA2])
        
        outer.value = inner2.eraseToAnyPublisher()
        
        inner1.send(0xA2)
        inner2.send(0xB2)
        
        inner1.send(0xA3)
        inner2.send(0xB3)
        
        XCTAssertEqual(results, [0xA2, 0xB2, 0xB3])
        XCTAssertFalse(completed)
        
        inner2.send(completion: .finished)
        
        XCTAssertFalse(completed)
    }
    
}
