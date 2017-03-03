//
//  FootProccesser.swift
//  navigation_foot_processing
//
//  Created by Игорь on 01.03.17.
//  Copyright © 2017 Игорь. All rights reserved.
//


import Foundation
import CoreMotion

protocol StepProcesserDelegate : class {
    func stepProcesser(processer: StepProcesser, getNewStep step : Step)
}

class StepProcesser {
    weak var delegate : StepProcesserDelegate?
    private let motionManager : CMMotionManager = CMMotionManager()
    
    func startMotionUpdate() {
        self.motionManager.startDeviceMotionUpdates(using: CMAttitudeReferenceFrame.xTrueNorthZVertical, to: OperationQueue.main) { /*[weak self]*/ (motion, error) in
//            print("\(motion?.userAcceleration.z)")
            self.pedometerProcess(acceleration: motion?.userAccelerationInReferenceFrame)
            self.addValue(value: motion?.userAcceleration)
        }
    }
    
    func stopUpdate() {
        self.motionManager.stopDeviceMotionUpdates()
    }
    
    // MARK: - store
    
    private var data = [(x: Double, y: Double, z: Double)]()
    
    private func addValue(value: CMAcceleration?) {
        if let value = value {
            self.data.append((x:value.x, y:value.y, z:value.z))
        }
        else {
            if let last = self.data.last {
                self.data.append(last)
            }
        }
    }
    
    func generateNewData() {
        self.data = [(x: Double, y: Double, z: Double)]()
    }
    
    func saveData() {
        let timestamp = Date()
        let fileName = timestamp.description + ".csv"
        
        var text = ""
        
        for value in self.data {
            text += "\(value.x)"+";"+"\(value.y)"+";"+"\(value.z)"+";" + "\n"
        }
        
        if let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let path = directory.appendingPathComponent(fileName)
            do {
                try text.write(to: path, atomically: false, encoding: String.Encoding.utf8)
            }
            catch {
                print("error")
            }

        }
        
        self.data = [(x: Double, y: Double, z: Double)]()
    }
    
    // Mark: - Extented pedometer
    
    private var max_value   = 0 as Double
    private var min_value   = 0 as Double
    
    // TODO: darvin
    
    private var max_timestamp  = Date()
    private var min_timestamp  = Date()
    
    
    private let peak_zerro_gate = 0.075
    private let zerro_gate      = 0.02
    
    private var currentStep     = Step()
    
    func pedometerProcess(acceleration: CMAcceleration?) {
        if let z = acceleration?.z {
            if abs(z) < 0.2 {
                if currentStep.max == nil && currentStep.min == nil {
                    print(" - wait new step")
                    max_timestamp = Date()
                }
                if currentStep.max != nil {
                    if currentStep.min == nil {
                        min_timestamp  = Date()
                        currentStep.up_timewidth    = -max_timestamp.timeIntervalSinceNow
                    }
                    else {
                        currentStep.down_timewidth  = -min_timestamp.timeIntervalSinceNow
                        self.processStep(step: currentStep)
                        currentStep = Step()
                    }
                    
                }
                else {
                    print(" - new step")
                    currentStep = Step()
                }
            }
            if z > max_value {
                max_value = z
                currentStep.max = max_value
            }
            else if z < -peak_zerro_gate {
                max_value = 0
            }
            if z < min_value {
                min_value = z
                currentStep.min = min_value
            }
            else if z > peak_zerro_gate {
                min_value = 0
            }
        }
    }
    
    func processStep(step: Step) {
        let timewidth = step.down_timewidth! + step.up_timewidth!
        if timewidth > 0.2 && timewidth < 0.8 {
            self.delegate?.stepProcesser(processer: self, getNewStep: step)
        }
        print("временная длина шага \(step.down_timewidth! + step.up_timewidth!)")
        
    }
    
}

extension CMDeviceMotion {
    
    var userAccelerationInReferenceFrame: CMAcceleration {
        let acc = self.userAcceleration
        let rot = self.attitude.rotationMatrix
        
        var accRef = CMAcceleration()
        accRef.x = acc.x*rot.m11 + acc.y*rot.m12 + acc.z*rot.m13;
        accRef.y = acc.x*rot.m21 + acc.y*rot.m22 + acc.z*rot.m23;
        accRef.z = acc.x*rot.m31 + acc.y*rot.m32 + acc.z*rot.m33;
        
        return accRef
    }
}


class Step {
    var max             : Double?
    var min             : Double?
    var up_timewidth    : TimeInterval?
    var down_timewidth  : TimeInterval?
}
