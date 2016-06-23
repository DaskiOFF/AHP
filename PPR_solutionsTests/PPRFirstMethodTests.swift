//
//  PPRFirstMethodTests.swift
//  PPR_solutions
//
//  Created by Roman Kotov on 25.04.16.
//  Copyright © 2016 Roman Kotov. All rights reserved.
//

import XCTest
import PPR_solutions

class PPRFirstMethodTests: XCTestCase {
    let solver = Solver()
    let accuracy = 0.05
    var target: Target!
    
    override func setUp() {
        super.setUp()
        
        self.target = Target(title: "Test target")
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func setupTarget() {
        // МПС критериев
        self.target.baseMPC = UsefulFirstMethod.targetMPC
        
        // Критерии и Альтернативы
        self.target.criterions = UsefulFirstMethod.criterions
        self.target.alternatives = UsefulFirstMethod.alternatives
        
        // МПС альтернатив
        self.target.criterionMPCs = UsefulFirstMethod.criterionMPCs
    }
}

extension PPRFirstMethodTests {
    func testGetterCriterionMPCs() {
        self.setupTarget()
        
        self.target.criterionMPCs = nil
        
        guard let mpcs = self.target.criterionMPCs else {
            XCTFail()
            return
        }
        
        XCTAssertGreaterThan(self.target.criterions.count, 0)
        
        for i in 0..<mpcs.count {
            XCTAssertEqual(mpcs[i].title.title, self.target.criterions[i].title)
            for j in 0..<mpcs[i].columns.count {
                XCTAssertEqual(mpcs[i].columns[j].title, self.target.alternatives[j].title)
            }
        }
    }
    
    func testMPCGetter() {
        self.setupTarget()
        
        guard var mpc = self.target.baseMPC else {
            XCTFail()
            return
        }
        
        let value = mpc[1, 2]
        let checkValue = 24.4
        
        mpc[1, 2] = checkValue
        
        XCTAssertEqual(mpc[1, 2], checkValue)
        XCTAssertNotEqual(mpc[1, 2], value)
    }
    
    func testFailSolve() {
        self.solver.findAlternativeForTarget(self.target).then { solve -> Void in
            XCTFail()
            }.error { _ in
                XCTAssertTrue(true)
        }
    }
    
    func testBaseMPC() {
        self.setupTarget()
        
        let expectation = self.expectationWithDescription("FirstMethod Test BaseMPC")
        
        self.solver.findAlternativeForTarget(target).then { solve -> Void in
            let solveTarget = solve.target
            // Сравниваем МПС критериев
            if let mpc = solveTarget.baseMPC, let eigenvector = mpc.eigenvector,
                let lambdaMax = mpc.lambdaMax, let iS = mpc.iS, let sI = mpc.sI, let oS = mpc.oS {
                
                let testResult = UsefulFirstMethod.targetSolvedMPC
                
                // Сумма элементов собственного вектора должна быть равна 1
                var sum = 0.0
                for i in 0..<testResult.eigenvector.count {
                    XCTAssertEqualWithAccuracy(eigenvector[i], testResult.eigenvector[i], accuracy: self.accuracy)
                    sum += eigenvector[i]
                }
                XCTAssertEqualWithAccuracy(sum, 1.0, accuracy: self.accuracy)
                
                XCTAssertEqualWithAccuracy(lambdaMax, testResult.lambdaMax, accuracy: self.accuracy)
                XCTAssertEqualWithAccuracy(iS, testResult.iS, accuracy: self.accuracy)
                XCTAssertEqual(sI, testResult.sI, "СИ должен совпадать")
                XCTAssertEqualWithAccuracy(oS, testResult.oS, accuracy: self.accuracy)
            } else {
                XCTFail()
            }
            
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testCriterionMPCs() {
        self.setupTarget()
        
        let expectation = self.expectationWithDescription("FirstMethod Test CriterionMPCs")
        
        self.solver.findAlternativeForTarget(target).then { solve -> Void in
            let solveTarget = solve.target
            
            // Сравниваем МПС альтернатив
            XCTAssertNotNil(solveTarget.criterionMPCs)
            
            let solverMPCs = UsefulFirstMethod.criterionSolvedMPCs
            let mpcs = solveTarget.criterionMPCs!
            
            for i in 0..<mpcs.count {
                let mpc = mpcs[i]
                let solverMPC = solverMPCs[i]
                
                if let eigenvector = mpc.eigenvector, let lambdaMax = mpc.lambdaMax,
                    let iS = mpc.iS, let sI = mpc.sI, let oS = mpc.oS {
                    
                    // Сумма элементов собственного вектора должна быть равна 1
                    var sum = 0.0
                    
                    for i in 0..<solverMPC.eigenvector.count {
                        XCTAssertEqualWithAccuracy(eigenvector[i], solverMPC.eigenvector[i], accuracy: self.accuracy)
                        sum += eigenvector[i]
                    }
                    XCTAssertEqualWithAccuracy(sum, 1.0, accuracy: self.accuracy)
                    
                    XCTAssertEqualWithAccuracy(lambdaMax, solverMPC.lambdaMax, accuracy: self.accuracy)
                    XCTAssertEqualWithAccuracy(iS, solverMPC.iS, accuracy: self.accuracy)
                    XCTAssertEqual(sI, solverMPC.sI, "СИ должен совпадать")
                    XCTAssertEqualWithAccuracy(oS, solverMPC.oS, accuracy: self.accuracy)
                } else {
                    XCTFail()
                }
            }
            
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testSynthesize() {
        self.setupTarget()
        
        let expectation = self.expectationWithDescription("FirstMethod Test Synthesize")
        
        self.solver.findAlternativeForTarget(target).then { solve -> Void in
            let solveTarget = solve.target
            
            // Сравниваем результат синтеза
            let synthesizeResult = UsefulFirstMethod.synthesizeResult
            
            for i in 0..<synthesizeResult.count {
                XCTAssertEqualWithAccuracy(solveTarget.alternatives[i].weight, synthesizeResult[i], accuracy: self.accuracy)
            }
            
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(5, handler: nil)
    }
}
