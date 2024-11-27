import Combine
import CombineExtensions
import XCTest

class CurrentValuePublisherTests: XCTestCase {
    
    // ============================================================================ //
    // MARK: - Constant Value
    // ============================================================================ //
    
    func testConstantValue() {
        var cancellables = Set<AnyCancellable>()
        var values = [String]()
        var completion: Subscribers.Completion<Never>?
        
        let publisher = CurrentValuePublisher<String, Never>(value: "constant")
        
        publisher
            .sink {
                completion = $0
            } receiveValue: {
                values.append($0)
            }
            .store(in: &cancellables)
        
        XCTAssertEqual(publisher.value, "constant")
        XCTAssertEqual(values, ["constant"])
        XCTAssertEqual(completion, .finished)
    }
    
    // ============================================================================ //
    // MARK: - Initial Value & Publisher
    // ============================================================================ //
    
    func testInitialValueAndPublisher_accessingValue() {
        let subject = PassthroughSubject<String, Never>()
        let publisher = CurrentValuePublisher(initial: "initial", upstream: subject)
        
        XCTAssertEqual(publisher.value, "initial")
        
        subject.send("second")
        XCTAssertEqual(publisher.value, "second")
        
        subject.send("third")
        XCTAssertEqual(publisher.value, "third")
    }
    
    func testInitialValueAndPublisher_receivingValues() {
        var cancellables = Set<AnyCancellable>()
        var values = [String]()
        
        let subject = PassthroughSubject<String, Never>()
        
        CurrentValuePublisher(initial: "initial", upstream: subject)
            .sink { values.append($0) }
            .store(in: &cancellables)
        
        XCTAssertEqual(values, ["initial"])
        
        subject.send("second")
        XCTAssertEqual(values, ["initial", "second"])
        
        subject.send("third")
        XCTAssertEqual(values, ["initial", "second", "third"])
    }
    
    func testInitialValueAndPublisher_completionFinished() {
        var cancellables = Set<AnyCancellable>()
        var completion: Subscribers.Completion<Never>?
        
        let subject = PassthroughSubject<String, Never>()
        
        CurrentValuePublisher(initial: "initial", upstream: subject)
            .sink(
                receiveCompletion: { completion = $0 },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
        
        XCTAssertNil(completion)
        
        subject.send(completion: .finished)
        XCTAssertEqual(completion, .finished)
    }
    
    func testInitialValueAndPublisher_completionFailure() {
        var cancellables = Set<AnyCancellable>()
        var completion: Subscribers.Completion<TestError>?
        
        let subject = PassthroughSubject<String, TestError>()
        
        CurrentValuePublisher(initial: "initial", upstream: subject)
            .sink(
                receiveCompletion: { completion = $0 },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
        
        XCTAssertNil(completion)
        
        subject.send(completion: .failure(TestError()))
        XCTAssertEqual(completion, .failure(TestError()))
    }
    
    func testInitialValueAndPublisher_cancellation() {
        var cancellables = Set<AnyCancellable>()
        var completion: Subscribers.Completion<Never>?
        var values = [String]()
        
        let subject = PassthroughSubject<String, Never>()
        
        CurrentValuePublisher(initial: "initial", upstream: subject)
            .sink(
                receiveCompletion: { completion = $0 },
                receiveValue: { values.append($0) }
            )
            .store(in: &cancellables)
        
        XCTAssertEqual(values, ["initial"])
        XCTAssertNil(completion)
        
        subject.send("second")
        XCTAssertEqual(values, ["initial", "second"])
        XCTAssertNil(completion)
        
        cancellables.forEach { $0.cancel() }
        XCTAssertEqual(values, ["initial", "second"])
        XCTAssertNil(completion)
        
        subject.send("third")
        XCTAssertEqual(values, ["initial", "second"])
    }
    
    // ============================================================================ //
    // MARK: - Subject
    // ============================================================================ //
    
    func testSubject_accessingValue() {
        let subject = CurrentValueSubject<String, Never>("initial")
        let publisher = CurrentValuePublisher(subject)
        
        XCTAssertEqual(publisher.value, "initial")
        
        subject.value = "second"
        XCTAssertEqual(publisher.value, "second")
        
        subject.value = "third"
        XCTAssertEqual(publisher.value, "third")
    }
    
    func testSubject_receivingValues() {
        var cancellables = Set<AnyCancellable>()
        var values = [String]()
        
        let subject = CurrentValueSubject<String, Never>("initial")
        
        CurrentValuePublisher(subject)
            .sink { values.append($0) }
            .store(in: &cancellables)
        
        XCTAssertEqual(values, ["initial"])
        
        subject.send("second")
        XCTAssertEqual(values, ["initial", "second"])
        
        subject.send("third")
        XCTAssertEqual(values, ["initial", "second", "third"])
    }
    
    func testSubject_receivingValues_multipleSubscriptions() {
        var cancellables = Set<AnyCancellable>()
        
        var values1 = [String]()
        var values2 = [String]()
        
        let subject = CurrentValueSubject<String, Never>("initial")
        let publisher = CurrentValuePublisher(subject)
        
        publisher
            .sink { values1.append($0) }
            .store(in: &cancellables)
        
        publisher
            .sink { values2.append($0) }
            .store(in: &cancellables)
        
        XCTAssertEqual(values1, ["initial"])
        XCTAssertEqual(values2, ["initial"])
        
        subject.send("second")
        XCTAssertEqual(values1, ["initial", "second"])
        XCTAssertEqual(values2, ["initial", "second"])
        
        subject.send("third")
        XCTAssertEqual(values1, ["initial", "second", "third"])
        XCTAssertEqual(values2, ["initial", "second", "third"])
    }
    
    func testSubject_completionFinished() {
        var cancellables = Set<AnyCancellable>()
        var completion: Subscribers.Completion<Never>?
        
        let subject = CurrentValueSubject<String, Never>("initial")
        
        CurrentValuePublisher(subject)
            .sink(
                receiveCompletion: { completion = $0 },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
        
        XCTAssertNil(completion)
        
        subject.send(completion: .finished)
        XCTAssertEqual(completion, .finished)
    }
    
    func testSubject_completionFailure() {
        var cancellables = Set<AnyCancellable>()
        var completion: Subscribers.Completion<TestError>?
        
        let subject = CurrentValueSubject<String, TestError>("initial")
        
        CurrentValuePublisher(subject)
            .sink(
                receiveCompletion: { completion = $0 },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
        
        XCTAssertNil(completion)
        
        subject.send(completion: .failure(TestError()))
        XCTAssertEqual(completion, .failure(TestError()))
    }
    
    // The cancellation behavior was verified by matching against a CurrentValueSubject wrapped
    // into a Publishers.Map publisher.
    func testSubject_cancellation() {
        var cancellables = Set<AnyCancellable>()
        var completion: Subscribers.Completion<Never>?
        var values = [String]()
        
        let subject = CurrentValueSubject<String, Never>("initial")
        
        CurrentValuePublisher(subject)
            .sink(
                receiveCompletion: { completion = $0 },
                receiveValue: { values.append($0) }
            )
            .store(in: &cancellables)
        
        XCTAssertEqual(values, ["initial"])
        XCTAssertNil(completion)
        XCTAssertEqual(subject.value, "initial")
        
        subject.send("second")
        XCTAssertEqual(values, ["initial", "second"])
        XCTAssertNil(completion)
        XCTAssertEqual(subject.value, "second")
        
        cancellables.forEach { $0.cancel() }
        XCTAssertEqual(values, ["initial", "second"])
        XCTAssertNil(completion)
        XCTAssertEqual(subject.value, "second")
        
        subject.send("third")
        XCTAssertEqual(values, ["initial", "second"])
        XCTAssertEqual(subject.value, "third")
    }
    
//    // ============================================================================ //
//    // MARK: - Published
//    // ============================================================================ //
//    
//    func testPublishedToCurrentValuePublisher_accessingValue() {
//        let object = MutableTestObject(initialValue: "initial")
//        let publisher = object.$value.toCurrentValuePublisher()
//        
//        XCTAssertEqual(publisher.value, "initial")
//        
//        object.value = "second"
//        XCTAssertEqual(publisher.value, "second")
//        
//        object.value = "third"
//        XCTAssertEqual(publisher.value, "third")
//    }
//    
//    func testPublishedToCurrentValuePublisher_receivingValues() {
//        var cancellables = Set<AnyCancellable>()
//        var values = [String]()
//        
//        let object = MutableTestObject(initialValue: "initial")
//        
//        object.$value
//            .toCurrentValuePublisher()
//            .sink { values.append($0) }
//            .store(in: &cancellables)
//        
//        XCTAssertEqual(values, ["initial"])
//        
//        object.value = "second"
//        XCTAssertEqual(values, ["initial", "second"])
//        
//        object.value = "third"
//        XCTAssertEqual(values, ["initial", "second", "third"])
//    }
//    
//    func testPublishedToCurrentValuePublisher_cancellation() {
//        var cancellables = Set<AnyCancellable>()
//        var values = [String]()
//        
//        let object = MutableTestObject(initialValue: "initial")
//        
//        object.$value
//            .toCurrentValuePublisher()
//            .sink { values.append($0) }
//            .store(in: &cancellables)
//        
//        XCTAssertEqual(values, ["initial"])
//        
//        object.value = "second"
//        XCTAssertEqual(values, ["initial", "second"])
//        
//        cancellables.forEach { $0.cancel() }
//        XCTAssertEqual(values, ["initial", "second"])
//        
//        object.value = "third"
//        XCTAssertEqual(values, ["initial", "second"])
//    }
//    
//    func testCurrentValuePublisherToPublished_accessingValue() {
//        let subject = CurrentValueSubject<String, Never>("initial")
//        let publisher = CurrentValuePublisher<String, Never>(subject)
//        let object = ImmutableTestObject(publisher: publisher)
//        
//        XCTAssertEqual(object.value, "initial")
//        
//        subject.value = "second"
//        XCTAssertEqual(object.value, "second")
//        
//        subject.value = "third"
//        XCTAssertEqual(object.value, "third")
//    }
//    
//    func testCurrentValuePublisherToPublished_completionFinished() {
//        let subject = CurrentValueSubject<String, Never>("initial")
//        let publisher = CurrentValuePublisher<String, Never>(subject)
//        let object = ImmutableTestObject(publisher: publisher)
//        
//        XCTAssertEqual(object.value, "initial")
//        
//        subject.send("second")
//        XCTAssertEqual(object.value, "second")
//        
//        subject.send(completion: .finished)
//        XCTAssertEqual(object.value, "second")
//    }
    
    // ============================================================================ //
    // MARK: - Map Operator
    // ============================================================================ //
    
    func testMap_constant() {
        var cancellables = Set<AnyCancellable>()
        var values = [String]()
        
        CurrentValuePublisher(value: 1)
            .map { "\($0)" }
            .sink { values.append($0) }
            .store(in: &cancellables)
        
        XCTAssertEqual(values, ["1"])
    }
    
    func testMap_subject_accessingValue() {
        let subject = CurrentValueSubject<Int, Never>(1)
        let publisher = CurrentValuePublisher(subject).map { "\($0)" }
        
        XCTAssertEqual(publisher.value, "1")
        
        subject.value = 2
        XCTAssertEqual(publisher.value, "2")
        
        subject.value = 3
        XCTAssertEqual(publisher.value, "3")
    }
    
    func testMap_subject_receivingValues() {
        var cancellables = Set<AnyCancellable>()
        var values = [String]()
        
        let subject = CurrentValueSubject<Int, Never>(1)
        
        CurrentValuePublisher(subject)
            .map { "\($0)" }
            .sink { values.append($0) }
            .store(in: &cancellables)
        
        XCTAssertEqual(values, ["1"])
        
        subject.send(2)
        XCTAssertEqual(values, ["1", "2"])
        
        subject.send(3)
        XCTAssertEqual(values, ["1", "2", "3"])
    }
    
    func testMap_subject_completionFinished() {
        var cancellables = Set<AnyCancellable>()
        var completion: Subscribers.Completion<Never>?
        
        let subject = CurrentValueSubject<Int, Never>(1)
        
        CurrentValuePublisher(subject)
            .map { "\($0)" }
            .sink(
                receiveCompletion: { completion = $0 },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
        
        XCTAssertNil(completion)
        
        subject.send(completion: .finished)
        XCTAssertEqual(completion, .finished)
    }
    
    func testMap_subject_completionFailure() {
        var cancellables = Set<AnyCancellable>()
        var completion: Subscribers.Completion<TestError>?
        
        let subject = CurrentValueSubject<Int, TestError>(1)
        
        CurrentValuePublisher(subject)
            .map { "\($0)" }
            .sink(
                receiveCompletion: { completion = $0 },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
        
        XCTAssertNil(completion)
        
        subject.send(completion: .failure(TestError()))
        XCTAssertEqual(completion, .failure(TestError()))
    }
    
    func testMap_subject_cancellation() {
        var cancellables = Set<AnyCancellable>()
        var completion: Subscribers.Completion<Never>?
        var values = [String]()
        
        let subject = CurrentValueSubject<Int, Never>(1)
        
        CurrentValuePublisher(subject)
            .map { "\($0)" }
            .sink(
                receiveCompletion: { completion = $0 },
                receiveValue: { values.append($0) }
            )
            .store(in: &cancellables)
        
        XCTAssertEqual(values, ["1"])
        XCTAssertNil(completion)
        
        subject.send(2)
        XCTAssertEqual(values, ["1", "2"])
        XCTAssertNil(completion)
        
        cancellables.forEach { $0.cancel() }
        XCTAssertEqual(values, ["1", "2"])
        XCTAssertNil(completion)
        
        subject.send(3)
        XCTAssertEqual(values, ["1", "2"])
    }
    
    // ============================================================================ //
    // MARK: - FlatMapLatest Operator
    // ============================================================================ //
    
    func testFlatMapLatest_constant_constant() {
        var cancellables = Set<AnyCancellable>()
        var values = [String]()
        
        CurrentValuePublisher(value: 1)
            .flatMapLatest { CurrentValuePublisher(value: "\($0)") }
            .sink { values.append($0) }
            .store(in: &cancellables)
        
        XCTAssertEqual(values, ["1"])
    }
    
    func testFlatMapLatest_constant_subject() {
        let subject = CurrentValueSubject<Int, Never>(1)
        let publisher = CurrentValuePublisher(subject)
        
        var cancellables = Set<AnyCancellable>()
        var values = [String]()
        
        CurrentValuePublisher(value: ())
            .flatMapLatest { _ in publisher.map { "\($0)" } }
            .sink { values.append($0) }
            .store(in: &cancellables)
        
        XCTAssertEqual(values, ["1"])
        
        subject.value = 2
        XCTAssertEqual(values, ["1", "2"])
    }
    
    func testFlatMapLatest_subject_constants() {
        let subject = CurrentValueSubject<Int, Never>(1)
        let publisher = CurrentValuePublisher(subject)
        
        var cancellables = Set<AnyCancellable>()
        var values = [String]()
        
        publisher
            .flatMapLatest { CurrentValuePublisher(value: "\($0)") }
            .sink { values.append($0) }
            .store(in: &cancellables)
        
        XCTAssertEqual(values, ["1"])
        
        subject.value = 2
        XCTAssertEqual(values, ["1", "2"])
        
        subject.value = 2
        XCTAssertEqual(values, ["1", "2", "2"])
    }
    
    func testFlatMapLatest_subject_subjects() {
        let innerSubject1 = CurrentValueSubject<Int, Never>(10)
        let innerPublisher1 = CurrentValuePublisher(innerSubject1)
        
        let innerSubject2 = CurrentValueSubject<Int, Never>(20)
        let innerPublisher2 = CurrentValuePublisher(innerSubject2)
        
        let outerSubject = CurrentValueSubject<CurrentValuePublisher<Int, Never>, Never>(innerPublisher1)
        let outerPublisher = CurrentValuePublisher(outerSubject)
        
        var cancellables = Set<AnyCancellable>()
        var values = [String]()
        
        outerPublisher
            .flatMapLatest { innerPublisher in
                innerPublisher.map { "\($0)" }
            }
            .sink { values.append($0) }
            .store(in: &cancellables)
        
        XCTAssertEqual(values, ["10"])
        
        innerSubject1.value = 11
        XCTAssertEqual(values, ["10", "11"])
        
        outerSubject.value = innerPublisher2
        innerSubject2.value = 21
        innerSubject2.value = 22
        XCTAssertEqual(values, ["10", "11", "20", "21", "22"])
        
        innerSubject1.value = 12
        outerSubject.value = innerPublisher1
        innerSubject1.value = 13
        XCTAssertEqual(values, ["10", "11", "20", "21", "22", "12", "13"])
    }
    
    func testFlatMapLatest_subject_subjectsAndConstants() {
        let innerSubject1 = CurrentValueSubject<Int, Never>(10)
        let innerPublisher1 = CurrentValuePublisher(innerSubject1)
        
        let innerPublisher2 = CurrentValuePublisher<Int, Never>(value: 20)
        let innerPublisher3 = CurrentValuePublisher<Int, Never>(value: 30)
        
        let outerSubject = CurrentValueSubject<CurrentValuePublisher<Int, Never>, Never>(innerPublisher1)
        let outerPublisher = CurrentValuePublisher(outerSubject)
        
        var cancellables = Set<AnyCancellable>()
        var values = [String]()
        
        outerPublisher
            .flatMapLatest { innerPublisher in
                innerPublisher.map { "\($0)" }
            }
            .sink { values.append($0) }
            .store(in: &cancellables)
        
        XCTAssertEqual(values, ["10"])
        
        innerSubject1.value = 11
        XCTAssertEqual(values, ["10", "11"])
        
        outerSubject.value = innerPublisher2
        XCTAssertEqual(values, ["10", "11", "20"])
        
        innerSubject1.value = 12
        outerSubject.value = innerPublisher1
        XCTAssertEqual(values, ["10", "11", "20", "12"])
        
        outerSubject.value = innerPublisher3
        outerSubject.value = innerPublisher3
        XCTAssertEqual(values, ["10", "11", "20", "12", "30", "30"])
        
        outerSubject.value = innerPublisher1
        XCTAssertEqual(values, ["10", "11", "20", "12", "30", "30", "12"])
    }
    
//    // ============================================================================ //
//    // MARK: - Remove Duplicates Operator
//    // ============================================================================ //
//    
//    func testRemoveDuplicates_constant() {
//        var cancellables = Set<AnyCancellable>()
//        var values = [Int]()
//        
//        CurrentValuePublisher(value: 1)
//            .removeDuplicates()
//            .sink { values.append($0) }
//            .store(in: &cancellables)
//        
//        XCTAssertEqual(values, [1])
//    }
//    
//    func testRemoveDuplicates_subject() {
//        var cancellables = Set<AnyCancellable>()
//        var values = [Int]()
//        
//        let subject = CurrentValueSubject<Int, Never>(1)
//        
//        CurrentValuePublisher(subject)
//            .removeDuplicates()
//            .sink { values.append($0) }
//            .store(in: &cancellables)
//        
//        XCTAssertEqual(values, [1])
//        
//        subject.send(1)
//        XCTAssertEqual(values, [1])
//        
//        subject.send(1)
//        XCTAssertEqual(values, [1])
//        
//        subject.send(2)
//        XCTAssertEqual(values, [1, 2])
//        
//        subject.send(2)
//        XCTAssertEqual(values, [1, 2])
//        
//        subject.send(3)
//        XCTAssertEqual(values, [1, 2, 3])
//    }
//    
//    func testRemoveDuplicate_subject_customPredicate() {
//        var cancellables = Set<AnyCancellable>()
//        var values = [Int]()
//        
//        let subject = CurrentValueSubject<Int, Never>(1)
//        
//        CurrentValuePublisher(subject)
//            .removeDuplicates(by: { old, new in new < old })
//            .sink { values.append($0) }
//            .store(in: &cancellables)
//        
//        XCTAssertEqual(values, [1])
//        
//        subject.send(4)
//        XCTAssertEqual(values, [1, 4])
//        
//        subject.send(3)
//        XCTAssertEqual(values, [1, 4])
//        
//        subject.send(6)
//        XCTAssertEqual(values, [1, 4, 6])
//        
//        subject.send(2)
//        XCTAssertEqual(values, [1, 4, 6])
//        
//        subject.send(7)
//        XCTAssertEqual(values, [1, 4, 6, 7])
//    }
//    
//    // ============================================================================ //
//    // MARK: - CombineLatest Operator
//    // ============================================================================ //
//    
//    func testCombineLatest_constants() {
//        var cancellables = Set<AnyCancellable>()
//        var values = [[Int]]()
//        
//        let publisher1 = CurrentValuePublisher<Int, Never>(value: 100)
//        let publisher2 = CurrentValuePublisher<Int, Never>(value: 200)
//        
//        publisher1.combineLatest(publisher2)
//            .sink { values.append([$0, $1]) }
//            .store(in: &cancellables)
//        
//        XCTAssertEqual(values, [[100, 200]])
//    }
//    
//    func testCombineLatest_subjects() {
//        var cancellables = Set<AnyCancellable>()
//        var values = [[Int]]()
//        
//        let subject1 = CurrentValueSubject<Int, Never>(100)
//        let publisher1 = CurrentValuePublisher(subject1)
//        
//        let subject2 = CurrentValueSubject<Int, Never>(200)
//        let publisher2 = CurrentValuePublisher(subject2)
//        
//        publisher1.combineLatest(publisher2)
//            .sink { values.append([$0, $1]) }
//            .store(in: &cancellables)
//        
//        XCTAssertEqual(values, [[100, 200]])
//        
//        subject1.send(101)
//        XCTAssertEqual(values, [[100, 200], [101, 200]])
//        
//        subject1.send(102)
//        XCTAssertEqual(values, [[100, 200], [101, 200], [102, 200]])
//        
//        subject2.send(201)
//        XCTAssertEqual(values, [[100, 200], [101, 200], [102, 200], [102, 201]])
//    }
//    
//    // ============================================================================ //
//    // MARK: - Boolean Operators
//    // ============================================================================ //
//    
//    func testBooleanAnd_constants() {
//        var cancellables = Set<AnyCancellable>()
//        var values = [Bool]()
//        
//        let publisher1 = CurrentValuePublisher<Bool, Never>(value: false)
//        let publisher2 = CurrentValuePublisher<Bool, Never>(value: true)
//        
//        publisher1.and(publisher2)
//            .sink { values.append($0) }
//            .store(in: &cancellables)
//        
//        XCTAssertEqual(values, [false])
//    }
//    
//    func testBooleanAnd_subjectAndConstant() {
//        var cancellables = Set<AnyCancellable>()
//        var values = [Bool]()
//        
//        let subject1 = CurrentValueSubject<Bool, Never>(false)
//        let publisher1 = CurrentValuePublisher(subject1)
//        
//        let publisher2 = CurrentValuePublisher<Bool, Never>(value: true)
//        
//        publisher1.and(publisher2)
//            .sink { values.append($0) }
//            .store(in: &cancellables)
//        
//        XCTAssertEqual(values, [false])
//        
//        subject1.value = true
//        XCTAssertEqual(values, [false, true])
//        
//        subject1.value = false
//        XCTAssertEqual(values, [false, true, false])
//    }
//    
//    func testBooleanAnd_subjects() {
//        var cancellables = Set<AnyCancellable>()
//        var values = [Bool]()
//        
//        let subject1 = CurrentValueSubject<Bool, Never>(false)
//        let publisher1 = CurrentValuePublisher(subject1)
//        
//        let subject2 = CurrentValueSubject<Bool, Never>(false)
//        let publisher2 = CurrentValuePublisher(subject2)
//        
//        publisher1.and(publisher2)
//            .sink { values.append($0) }
//            .store(in: &cancellables)
//        
//        XCTAssertEqual(values, [false])
//        
//        subject1.value = true
//        XCTAssertEqual(values, [false, false])
//        
//        subject2.value = true
//        XCTAssertEqual(values, [false, false, true])
//        
//        subject1.value = false
//        XCTAssertEqual(values, [false, false, true, false])
//    }
//    
//    func testBooleanOr_constants() {
//        var cancellables = Set<AnyCancellable>()
//        var values = [Bool]()
//        
//        let publisher1 = CurrentValuePublisher<Bool, Never>(value: false)
//        let publisher2 = CurrentValuePublisher<Bool, Never>(value: true)
//        
//        publisher1.or(publisher2)
//            .sink { values.append($0) }
//            .store(in: &cancellables)
//        
//        XCTAssertEqual(values, [true])
//    }
//    
//    func testBooleanOr_subjectAndConstant() {
//        var cancellables = Set<AnyCancellable>()
//        var values = [Bool]()
//        
//        let subject1 = CurrentValueSubject<Bool, Never>(false)
//        let publisher1 = CurrentValuePublisher(subject1)
//        
//        let publisher2 = CurrentValuePublisher<Bool, Never>(value: false)
//        
//        publisher1.or(publisher2)
//            .sink { values.append($0) }
//            .store(in: &cancellables)
//        
//        XCTAssertEqual(values, [false])
//        
//        subject1.value = true
//        XCTAssertEqual(values, [false, true])
//        
//        subject1.value = false
//        XCTAssertEqual(values, [false, true, false])
//    }
//    
//    func testBooleanOr_subjects() {
//        var cancellables = Set<AnyCancellable>()
//        var values = [Bool]()
//        
//        let subject1 = CurrentValueSubject<Bool, Never>(true)
//        let publisher1 = CurrentValuePublisher(subject1)
//        
//        let subject2 = CurrentValueSubject<Bool, Never>(true)
//        let publisher2 = CurrentValuePublisher(subject2)
//        
//        publisher1.or(publisher2)
//            .sink { values.append($0) }
//            .store(in: &cancellables)
//        
//        XCTAssertEqual(values, [true])
//        
//        subject1.value = false
//        XCTAssertEqual(values, [true, true])
//        
//        subject2.value = false
//        XCTAssertEqual(values, [true, true, false])
//        
//        subject1.value = true
//        XCTAssertEqual(values, [true, true, false, true])
//    }
    
    // ============================================================================ //
    // MARK: - Deinitialization
    // ============================================================================ //
    
    func testDeinit_clearingVariableWithCancelledSubscription() {
        let subject = CurrentValueSubject<Int, Never>(1)
        var publisher: CurrentValuePublisher? = CurrentValuePublisher(subject)
        weak var weakPublisher = publisher
        XCTAssertNotNil(weakPublisher)
        
        let cancellable = publisher?.sink(receiveValue: { _ in })
        XCTAssertNotNil(weakPublisher)
        
        cancellable?.cancel()
        XCTAssertNotNil(weakPublisher)
        
        publisher = nil
        XCTAssertNil(weakPublisher)
    }
    
    func testDeinit_cancellingLastSubscription() {
        let subject = CurrentValueSubject<Int, Never>(1)
        var publisher: CurrentValuePublisher? = CurrentValuePublisher(subject)
        weak var weakPublisher = publisher
        XCTAssertNotNil(weakPublisher)
        
        let cancellable1 = publisher?.sink(receiveValue: { _ in })
        let cancellable2 = publisher?.sink(receiveValue: { _ in })
        XCTAssertNotNil(weakPublisher)
        
        publisher = nil
        XCTAssertNotNil(weakPublisher)
        
        cancellable2?.cancel()
        XCTAssertNotNil(weakPublisher)
        
        cancellable1?.cancel()
        XCTAssertNil(weakPublisher)
    }
    
    func testDeinit_clearingVariablesForChainedMapOperator() {
        let subject = CurrentValueSubject<Int, Never>(1)
        
        var publisher1: CurrentValuePublisher? = CurrentValuePublisher(subject)
        weak var weakPublisher1 = publisher1
        
        var publisher2: CurrentValuePublisher? = publisher1?.map(\.self)
        weak var weakPublisher2 = publisher2
        
        var publisher3: CurrentValuePublisher? = publisher2?.map(\.self)
        weak var weakPublisher3 = publisher3
        
        publisher1 = nil
        XCTAssertNotNil(weakPublisher1)
        XCTAssertNotNil(weakPublisher2)
        XCTAssertNotNil(weakPublisher3)
        
        publisher3 = nil
        XCTAssertNotNil(weakPublisher1)
        XCTAssertNotNil(weakPublisher2)
        XCTAssertNil(weakPublisher3)
        
        publisher2 = nil
        XCTAssertNil(weakPublisher1)
        XCTAssertNil(weakPublisher2)
        XCTAssertNil(weakPublisher3)
    }
    
    func testDeinit_cancellingSubscriptionOnMapOperator() {
        let subject = CurrentValueSubject<Int, Never>(1)
        
        var publisher1: CurrentValuePublisher? = CurrentValuePublisher(subject)
        weak var weakPublisher1 = publisher1
        
        var publisher2: CurrentValuePublisher? = publisher1?.map(\.self)
        weak var weakPublisher2 = publisher2
        
        let cancellable = publisher2?.sink(receiveValue: { _ in })
        
        publisher1 = nil
        publisher2 = nil
        XCTAssertNotNil(weakPublisher1)
        XCTAssertNotNil(weakPublisher2)
        
        cancellable?.cancel()
        XCTAssertNil(weakPublisher1)
        XCTAssertNil(weakPublisher2)
    }
    
}

fileprivate struct TestError: Error, Equatable {}

fileprivate class MutableTestObject {
    
    fileprivate init(initialValue: String) {
        self.value = initialValue
    }
    
    @Published
    fileprivate var value: String
    
}

//fileprivate class ImmutableTestObject {
//    
//    fileprivate init(publisher: CurrentValuePublisher<String, Never>) {
//        self._value = Published(publisher)
//    }
//    
//    @Published
//    fileprivate private(set) var value: String
//    
//}
