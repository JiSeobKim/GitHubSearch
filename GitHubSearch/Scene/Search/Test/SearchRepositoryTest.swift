//
//  SearchRepositoryTest.swift
//  GitHubSearch
//
//  Created by 김지섭 on 2022/01/04.
//

@testable import GitHubSearch
import XCTest
import RxSwift

class SearchRepositoryTest: XCTestCase {
    private var sut: SearchRepository!
    private var bag: DisposeBag!
    
    override func setUp() {
        super.setUp()
        
        sut = SearchRepositoryImp()
        bag = DisposeBag()
    }
    
    // 가져오기 테스트
    func testFetch() {
        // given
        var result: RepositoryListInfo?
        let expFetch = XCTestExpectation()
        
        sut.result
            .skip(1)
            .subscribe(onNext: { info in
                result = info
                expFetch.fulfill()
            }).disposed(by: bag)
        
        // when
        sut.fetch(keyword: "Pokemon", page: 1)
        wait(for: [expFetch], timeout: 3)
        
        
        // then
        XCTAssertGreaterThan(result?.totalCount ?? 0, 0)
        XCTAssertGreaterThan(result?.repoList.count ?? 0, 0)
    }
    
    // Page 테스트
    func testFetchForPage() {
        // given
        var resultList: [RepositoryListInfo] = []
        let expFetch = XCTestExpectation()
        
        sut.result
            .skip(1)
            .subscribe(onNext: { info in
                resultList.append(info)
                if resultList.count == 2 {
                    expFetch.fulfill()
                }
            }).disposed(by: bag)
        
        // when
        sut.fetch(keyword: "Pokemon", page: 1)
        sut.fetch(keyword: "Pokemon", page: 2)
        wait(for: [expFetch], timeout: 3)
        
        
        // then
        let firstID = resultList.first?.repoList.first?.id
        let secondID = resultList.last?.repoList.first?.id
        XCTAssertNotEqual(firstID, secondID)
    }
    
    // Per Page 테스트
    func testFetchForPerPage() {
        // given
        let expFetch20 = XCTestExpectation()
        let expFetch40 = XCTestExpectation()
        
        var perPage30 = false
        var perPage40 = false
        
        sut.result
            .skip(1)
            .subscribe(onNext: { info in
                if self.sut.perPage == 20 && info.repoList.count == 20 {
                    perPage30 = true
                    expFetch20.fulfill()
                }
                
                if self.sut.perPage == 40 && info.repoList.count == 40 {
                    perPage40 = true
                    expFetch40.fulfill()
                }
            }).disposed(by: bag)
        
        // when
        sut.perPage = 20
        sut.fetch(keyword: "Pokemon", page: 1)
        wait(for: [expFetch20], timeout: 3)
        
        sut.perPage = 40
        sut.fetch(keyword: "Pokemon", page: 1)
        wait(for: [expFetch40], timeout: 3)
        
        
        // then
        XCTAssertTrue(perPage30)
        XCTAssertTrue(perPage40)
    }
    
    // 통신중 나타내기 테스트
    func testOnNetworking() {
        // given
        var result: [Bool] = []
        let expFetch = XCTestExpectation()
        
        sut.onNetworking
            .subscribe(onNext: { isOn in
                result.append(isOn)
                if result.count == 2 {
                    expFetch.fulfill()
                }
            }).disposed(by: bag)
        
        // when
        sut.fetch(keyword: "Pokemon", page: 1)
        wait(for: [expFetch], timeout: 1)
        
        // then
        XCTAssertEqual(result, [true, false])
    }
}
