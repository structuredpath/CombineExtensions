import CombineExtensions
import Combine
import XCTest

class WithPreviousTests: XCTestCase {
    
    func testWithPrevious_optional() {
        var cancellables = Set<AnyCancellable>()
        
        let subject = PassthroughSubject<Int, Never>()
        var results: [[Int?]] = []
        var completed = false
        
        subject
            .withPrevious()
            .sink { _ in
                completed = true
            } receiveValue: { pair in
                results.append([pair.previous, pair.current])
            }
            .store(in: &cancellables)
        
        XCTAssertTrue(results.isEmpty)
        XCTAssertFalse(completed)
        
        subject.send(1)
        subject.send(2)
        subject.send(3)
        
        XCTAssertEqual(results, [[nil, 1], [1, 2], [2, 3]])
        XCTAssertFalse(completed)
        
        subject.send(completion: .finished)
        XCTAssertTrue(completed)
    }
    
    func testWithPrevious_initialValue() {
        var cancellables = Set<AnyCancellable>()
        
        let subject = PassthroughSubject<Int, Never>()
        var results: [[Int]] = []
        var completed = false
        
        subject
            .withPrevious(initialValue: 0)
            .sink { _ in
                completed = true
            } receiveValue: { pair in
                results.append([pair.previous, pair.current])
            }
            .store(in: &cancellables)
        
        XCTAssertTrue(results.isEmpty)
        XCTAssertFalse(completed)
        
        subject.send(1)
        subject.send(2)
        subject.send(3)
        
        XCTAssertEqual(results, [[0, 1], [1, 2], [2, 3]])
        XCTAssertFalse(completed)
        
        subject.send(completion: .finished)
        XCTAssertTrue(completed)
    }
    
    func testWithPrevious_optional_emptyStream() {
        var cancellables = Set<AnyCancellable>()
        
        var results: [[Int?]] = []
        var completed = false
        
        Empty(completeImmediately: true)
            .setFailureType(to: Never.self)
            .withPrevious()
            .sink { _ in completed = true } receiveValue: { pair in
                results.append([pair.previous, pair.current])
            }
            .store(in: &cancellables)
        
        XCTAssertTrue(results.isEmpty)
        XCTAssertTrue(completed)
    }
    
    func testWithPrevious_initialValue_emptyStream() {
        var cancellables = Set<AnyCancellable>()
        
        var results: [[Int]] = []
        var completed = false
        
        Empty(completeImmediately: true)
            .setFailureType(to: Never.self)
            .withPrevious(initialValue: 0)
            .sink { _ in completed = true } receiveValue: { pair in
                results.append([pair.previous, pair.current])
            }
            .store(in: &cancellables)
        
        XCTAssertTrue(results.isEmpty)
        XCTAssertTrue(completed)
    }
    
    func testWithPrevious_doesNotRetainObjects() {
        var cancellables = Set<AnyCancellable>()
        var deallocatedIDs = Set<Int>()
        
        let subject = PassthroughSubject<TestObject, Never>()
        
        subject
            .withPrevious()
            .sink { _ in }
            .store(in: &cancellables)
        
        for id in 0...2 {
            let object = TestObject(id: id) { deallocatedIDs.insert(id) }
            subject.send(object)
        }
        
        XCTAssertEqual(deallocatedIDs, [0, 1])
        
        subject.send(completion: .finished)
        XCTAssertEqual(deallocatedIDs, [0, 1, 2])
    }
    
}

private final class TestObject {
    let id: Int
    let onDeinit: () -> Void
    
    init(id: Int, onDeinit: @escaping () -> Void) {
        self.id = id
        self.onDeinit = onDeinit
    }
    
    deinit {
        self.onDeinit()
    }
}
