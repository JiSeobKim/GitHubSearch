//
//  SearchViewModelTest.swift
//  GitHubSearch
//
//  Created by 김지섭 on 2022/01/04.
//

@testable import GitHubSearch
import XCTest
import RxSwift
import RxRelay

class SearchViewModelTest: XCTestCase {
    private var sut: SearchViewModel!
//    private var interactor: SearchInteractor!
    private var repository: SearchRepositoryMock!
    private var bag: DisposeBag!
    
    
    override func setUp() {
        super.setUp()
        repository = SearchRepositoryMock()
        let interactor = SearchInteractorImp(repository:  repository)
        sut = SearchViewModelImp(interactor: interactor)
        bag = DisposeBag()
    }
    
    // 키워드 입력시 데이터 및 새로고침 방출
    func testNewKeyword() {
        // given
        let expFetch = XCTestExpectation()
        var isReload = false
        
        sut.tableReload
            .subscribe(onNext: { _ in
                isReload = true
                expFetch.fulfill()
            }).disposed(by: bag)
        
        // when
        sut.updateKeyword("poke")
        wait(for: [expFetch], timeout: 5)
        
        // then
        XCTAssertEqual(repository.fetchCallCount, 1)
        XCTAssertTrue(isReload)
        XCTAssertGreaterThan(sut.repoList.count, 0)
    }
    
    // 더 불러오기시 데이터 및 insert 방출
    func testLoadMore() {
        // given
        let expFetchLoad = XCTestExpectation()
        let expFetchMore = XCTestExpectation()
        
        var indexes: [IndexPath] = []
        
        sut.tableReload
            .subscribe(onNext: { _ in
                expFetchLoad.fulfill()
            }).disposed(by: bag)
        
        sut.tableInsert
            .subscribe(onNext: { newIndexes in
                indexes = newIndexes
                expFetchMore.fulfill()
            }).disposed(by: bag)
        
        // when
        repository.perPage = 20
        sut.updateKeyword("poke")
        wait(for: [expFetchLoad], timeout: 5)
        
        sut.loadMore()
        wait(for: [expFetchMore], timeout: 5)
        
        // then
        XCTAssertEqual(repository.fetchCallCount, 2)
        XCTAssertEqual(indexes.first?.row, 20)
        XCTAssertEqual(indexes.last?.row, 39)
        XCTAssertEqual(sut.repoList.count, 40)
        XCTAssertGreaterThan(indexes.count, 0)
    }
    
    // 키워드 삭제시 데이터 제거 및 새로고침
    func testClear() {
        // given
        let expFetch = XCTestExpectation()
        let expClear = XCTestExpectation()
        var isReload: [Bool] = []
        var callCount = 0
        
        
        sut.tableReload
            .subscribe(onNext: { _ in
                isReload.append(true)
                switch callCount {
                case 1:
                    expFetch.fulfill()
                case 2:
                    expClear.fulfill()
                default:
                    break
                }
                
            }).disposed(by: bag)
        
        // when
        callCount += 1
        sut.updateKeyword("poke")
        
        wait(for: [expFetch], timeout: 2)
        
        callCount += 1
        sut.clear()
        wait(for: [expClear], timeout: 2)
        
        // then
        XCTAssertEqual(repository.fetchCallCount, 1)
        XCTAssertEqual(isReload, [true, true])
        XCTAssertEqual(sut.repoList.count, 0)
    }
    
    // ErrorMessage 테스트
    func testErrorMessage() {
        // given
        let expFetch = XCTestExpectation()
        var message: String?
        repository.isSuccessTest = false
        
        sut.showMessage
            .subscribe(onNext: { msg in
                message = msg
                expFetch.fulfill()
            }).disposed(by: bag)
        
        // when
        sut.updateKeyword("poke")
        wait(for: [expFetch], timeout: 3)
        
        // then
        XCTAssertEqual(repository.fetchCallCount, 1)
        XCTAssertEqual(message, "Error")
        XCTAssertEqual(sut.repoList.count, 0)
    }
    
    // isLoading 테스트 (통신 성공)
    func testIsLoadingOnSuccess() {
        // given
        let expFetch = XCTestExpectation()
        var result: [Bool] = []
        
        sut.isLoading
            .subscribe(onNext: { isOn in
                result.append(isOn)
                if result.count == 2 {
                    expFetch.fulfill()
                }
            }).disposed(by: bag)
        
        // when
        sut.updateKeyword("poke")
        wait(for: [expFetch], timeout: 3)
        
        // then
        XCTAssertEqual(repository.fetchCallCount, 1)
        XCTAssertEqual(result, [true, false])
    }
    
    // isLoading 테스트 (통신 실패)
    func testIsLoadingOnFailure() {
        // given
        let expFetch = XCTestExpectation()
        var result: [Bool] = []
        
        repository.isSuccessTest = false
        
        sut.isLoading
            .subscribe(onNext: { isOn in
                result.append(isOn)
                if result.count == 2 {
                    expFetch.fulfill()
                }
            }).disposed(by: bag)
        
        // when
        sut.updateKeyword("poke")
        wait(for: [expFetch], timeout: 3)
        
        // then
        XCTAssertEqual(repository.fetchCallCount, 1)
        XCTAssertEqual(result, [true, false])
    }
}
