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
            .subscribe(onNext: { info in
                result = info
                expFetch.fulfill()
            }).disposed(by: bag)
        
        // when
        sut.fetch(keyword: "Pokemon", page: 1)
        wait(for: [expFetch], timeout: 1)
        
        
        // then
        XCTAssertGreaterThan(result?.totalCount ?? 0, 0)
        XCTAssertGreaterThan(result?.items.count ?? 0, 0)
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
        sut.fetch(keyword: "Pokemon")
        wait(for: [expFetch], timeout: 1)
        
        // then
        XCTAssertEqual(result, [true, false])
    }
}
