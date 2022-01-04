//
//  SearchTableViewModelTest.swift
//  GitHubSearch
//
//  Created by 김지섭 on 2022/01/04.
//

@testable import GitHubSearch
import XCTest
import RxSwift

class SearchTableViewModelTest: XCTestCase {
    private var bag: DisposeBag!
    
    override func setUp() {
        super.setUp()
        bag = DisposeBag()
    }
    
    // 가져오기 테스트
    func testFetch() {
        // given
        let repo = SearchRepositoryImp()
        var sut: SearchTableViewModel?
        let expFetch = XCTestExpectation()
        
        repo.result
            .skip(1)
            .subscribe(onNext: { info in
                if let repo = info.repoList.first {
                    sut = SearchTableViewModel(repo)
                }
                expFetch.fulfill()
            }).disposed(by: bag)
        
        // when
        repo.fetch(keyword: "Pokemon", page: 1)
        wait(for: [expFetch], timeout: 3)
        
        
        // then
        XCTAssertNotNil(sut?.userName)
        XCTAssertNotNil(sut?.repositoryName)
        XCTAssertNotNil(sut?.description)
        XCTAssertNotNil(sut?.watchersCount)
        XCTAssertNotNil(sut?.avataImgURL)
    }
}


