//
//  PPRSecondMethodTests.swift
//  PPR_solutions
//
//  Created by Roman Kotov on 28.04.16.
//  Copyright © 2016 Roman Kotov. All rights reserved.
//

import XCTest
@testable import PPR_solutions

class PPRSecondMethodTests: XCTestCase {
    let solver = Solver()
    let accuracy = 0.05
    var target: Target!
    
    override func setUp() {
        super.setUp()
        
        self.target = Target(title: "Test target", method: .AllocationOfResources)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func setupTarget() {
        // МПС критериев
        self.target.baseMPC = UsefulSecondMethod.targetMPC
        
        // Критерии и Альтернативы
        self.target.criterions = UsefulSecondMethod.criterions
        self.target.alternatives = UsefulSecondMethod.alternatives
        
        // МПС альтернатив
        self.target.criterionMPCs = UsefulSecondMethod.criterionMPCs
    }
}

extension PPRSecondMethodTests {
    func testBadTarget() {
        let expectation = self.expectationWithDescription("SecondMethod Test BadTarget")
        
        self.solver.findProjects(target, forBudget: 100).then { solve -> Void in
            XCTFail()
        }.error { (_) in
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testBadBudget() {
        self.setupTarget()
        
        let expectation = self.expectationWithDescription("SecondMethod Test BadBudget")
        
        self.solver.findProjects(target, forBudget: -1).then { solve -> Void in
            XCTFail()
        }.error { (_) in
                expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testBaseMPC() {
        self.setupTarget()
        
        let expectation = self.expectationWithDescription("SecondMethod Test BaseMPC")
        
        self.solver.findProjects(target, forBudget: 100).then { solve -> Void in
            let solveTarget = solve.target
            // Сравниваем МПС критериев
            if let mpc = solveTarget.baseMPC, let eigenvector = mpc.eigenvector {
                
                let testResult = UsefulSecondMethod.targetSolvedMPC
                
                // Сумма элементов собственного вектора должна быть равна 1
                var sum = 0.0
                for i in 0..<testResult.count {
                    XCTAssertEqualWithAccuracy(eigenvector[i], testResult[i], accuracy: self.accuracy)
                    sum += eigenvector[i]
                }
                XCTAssertEqualWithAccuracy(sum, 1.0, accuracy: self.accuracy)
                
            } else {
                XCTFail()
            }
            
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testUsefulness() {
        self.setupTarget()
        
        let expectation = self.expectationWithDescription("SecondMethod Test Usefulness")
        
        self.solver.findProjects(target, forBudget: 100).then { solve -> Void in
            let solveTarget = solve.target
            let projects = UsefulSecondMethod.alternatives
            let projectsUsefulness = UsefulSecondMethod.usefulnessResult
            
            XCTAssertEqual(solveTarget.alternatives.count, projects.count)
        
            for i in 0..<projectsUsefulness.count {
                if let project = solveTarget.alternatives[i] as? BaseProjectProtocol {
                    XCTAssertEqualWithAccuracy(project.usefulness, projectsUsefulness[i], accuracy: self.accuracy)
                } else {
                    XCTFail()
                }
            }
            
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testResultProjects() {
        self.setupTarget()
        
        let expectation = self.expectationWithDescription("SecondMethod Test Result Projects")
        
        self.solver.findProjects(target, forBudget: 100).then { solve -> Void in
            XCTAssertEqual(solve.projects.count, 3)
            
            let projects = UsefulSecondMethod.alternatives
            XCTAssertEqual(solve.projects[0].title, projects[3].title)
            XCTAssertEqual(solve.projects[1].title, projects[4].title)
            XCTAssertEqual(solve.projects[2].title, projects[6].title)
            
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testResultProjectsAnotherBudget() {
        self.setupTarget()
        
        let expectation = self.expectationWithDescription("SecondMethod Test Result Budget 190")
        
        self.solver.findProjects(target, forBudget: 190).then { solve -> Void in
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(5, handler: nil)
        
        let expectation2 = self.expectationWithDescription("SecondMethod Test Result Budget 340")
        
        self.solver.findProjects(target, forBudget: 340).then { solve -> Void in
            expectation2.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testRandomProjects() {
        var projects = UsefulSecondMethod.alternativesPerformance
        let localSolver = SolverLinear()
        
        for _ in 0..<10 {
            projects = projects.shuffle()
            var maxBudget = 0.0
            for var project in projects {
                project.weight = Double(Double(arc4random()) / Double(UINT32_MAX) * 100.0)
                project.usefulness = Double(Double(arc4random()) / Double(UINT32_MAX))
                maxBudget += project.weight
            }
            
            let budget = Double(arc4random_uniform(UInt32(maxBudget)))
            
            let projsBF = localSolver.brutforceForProjects(projects, andBudget: budget)
            let projsMM = localSolver.meetInTheMiddleForProjects(projects, andBudget: budget)
            
            XCTAssertEqual(projsBF.count, projsMM.count)
            var bfs = ""
            var bfs1 = 0.0, bfs2 = 0.0
            var mms = ""
            var mms1 = 0.0, mms2 = 0.0
            
            projsBF.forEach({ (el) in
                bfs += " \(el.title)"
                bfs1 += el.usefulness
                bfs2 += el.weight
            })
            
            projsMM.forEach({ (el) in
                mms += " \(el.title)"
                mms1 += el.usefulness
                mms2 += el.weight
            })
            
            print("-----------\(budget) <= \(maxBudget)-------------")
            print("\(bfs) | \(bfs1) | \(bfs2)")
            print("\(mms) | \(mms1) | \(mms2)")
            print("-------------------------")
    
            for j in 0..<projsBF.count where projsBF.count > 0 {
                XCTAssertEqual(projsBF[j].title, projsMM[j].title, "\(budget)")
            }
        }
        
        var projsBF = localSolver.brutforceForProjects(projects, andBudget: 0)
        var projsMM = localSolver.meetInTheMiddleForProjects(projects, andBudget: 0)
        
        for j in 0..<projsBF.count where projsBF.count > 0 {
            XCTAssertEqual(projsBF[j].title, projsMM[j].title, "\(0)")
        }
        
        for j in 0..<projsBF.count where projsBF.count > 0 {
            XCTAssertEqual(projsBF[j].title, projsMM[j].title, "\(0)")
        }
        
        projsBF = localSolver.brutforceForProjects(projects, andBudget: 100000)
        projsMM = localSolver.meetInTheMiddleForProjects(projects, andBudget: 100000)
        
        for j in 0..<projsBF.count where projsBF.count > 0 {
            XCTAssertEqual(projsBF[j].title, projsMM[j].title, "\(100000)")
        }
        
        for j in 0..<projsBF.count where projsBF.count > 0 {
            XCTAssertEqual(projsBF[j].title, projsMM[j].title, "\(100000)")
        }
    }
    
    func testPerformanceBrutForce() {
        let projects = UsefulSecondMethod.alternativesPerformance
        let localSolver = SolverLinear()
        
        self.measureBlock {
            localSolver.brutforceForProjects(projects, andBudget: 100)
        }
    }
    
    func testPerformanceMeetInTheMiddle() {
        let projects = UsefulSecondMethod.alternativesPerformance
        let localSolver = SolverLinear()
        
        self.measureBlock {
            localSolver.meetInTheMiddleForProjects(projects, andBudget: 100)
        }
    }
}
