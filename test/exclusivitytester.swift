//
//  exclusivitytester.swift
//  test
//
//  Created by James Clarke on 7/8/23.
//

import Foundation

func address(o: UnsafeRawPointer) -> Int {
    return Int(Int(bitPattern: o))
}

public struct Memory<AddressSize> where AddressSize : BinaryInteger {
    private var buffer : [AddressSize]
    
    public init(sizeInBytes: Int) {
        buffer = Array(repeating: 0, count: sizeInBytes)
    }
    
    public mutating func SetAddress(_ offset: Int, _ value: AddressSize) {
        buffer[offset] = value
    }
    
    public mutating func PrintStructAddress () {
        print("Memory address for self:", NSString(format: "%p", address(o: &self)))
        printAddress(address: buffer)
    }
    
    public func PrintBufferAddress () {
        printAddress(address: buffer)
    }
    
    private func printAddress(address o: UnsafeRawPointer ) {
        print("Memory buffer address:", String(format: "%p", Int(bitPattern: o)))
    }
}

struct ExclusivityTester {
    
    public typealias Callback = (UInt16) -> UInt8
    
    public typealias CallbackPassArg = (UInt16, ExclusivityTester) -> UInt8
    
    public typealias CallbackPassArgInout = (UInt16, inout ExclusivityTester) -> UInt8
    
    public var memory: Memory<UInt16>
    public var c: Int32
    
    private var CallbackPassArgInout: CallbackPassArgInout
    private var CallbackPassArg: CallbackPassArg
    private var CallbackCaptureGlobal: Callback
    
    public init(memory: Memory<UInt16>,
                _ passArg: @escaping CallbackPassArg,
                _ passArgInout: @escaping CallbackPassArgInout,
                _ captureGlobal: @escaping Callback)
    {
        self.memory = memory
        self.CallbackPassArg = passArg
        self.CallbackPassArgInout = passArgInout
        self.CallbackCaptureGlobal = captureGlobal
        c = 1
    }
    
    public mutating func PrintAddress() {
        print("ExclusivityTester self:", NSString(format: "%p", address(o: &self)))
    }
    
    public mutating func doSomethingmutcbcaptureglobalEscaping() {
        self.c += 1
        print("START doSomethingmutcbcaptureglobalEscaping")
        let result = self.CallbackCaptureGlobal(2)
        print("Result from callback :\(result)")
        print("END doSomethingmutcbcaptureglobalEscaping")
    }
    
    public mutating func doSomethingmutcbcaptureglobalNonEscaping(callBack: Callback) {
        print("START doSomethingmutcbcaptureglobalNonEscaping")
        self.c += 1
        let result = callBack(2)
        print("Result from callback :\(result)")
        print("END doSomethingmutcbcaptureglobalNonEscaping")
    }
    
    public mutating func DoSomethingMutCbPassArgEscaping(_ printMemory: Bool) {
        print("START DoSomethingMutCbPassArgEscaping")
        self.c += 1
        let result = self.CallbackPassArg(2, self)
        print("Result from callback :\(result) value of c:\(self.c)")
        if printMemory {
            self.memory.PrintStructAddress()
        }
        print("END DoSomethingMutCbPassArgEscaping")
    }
    
    public mutating func DoSomethingMutCbPassArgNonEscaping(printmemory: Bool, callBack: CallbackPassArg) {
        print("START DoSomethingMutCbPassArgNonEscaping")
        self.c += 1
        if printmemory {
            self.PrintAddress()
        }
        let result = callBack(2, self)
        print("Result from callback :\(result) value of c:\(self.c)")
        if printmemory {
            self.memory.PrintStructAddress()
        }
        print("END DoSomethingMutCbPassArgNonEscaping")
    }
    
    public mutating func doSomethingmutcbPassArgInOutEscaping() {
        print("START doSomethingmutcbPassArgInOutEscaping")
        self.c += 1
        let result = self.CallbackPassArgInout(2, &self)
        print("Result from callback :\(result) value of c:\(self.c)")
        print("END doSomethingmutcbPassArgInOutEscaping")
    }
    
    public func DoSomethingCbPassNonEscaping(callBack: CallbackPassArg) {
        print("START DoSomethingCbPassNonEscaping")
        let result = callBack(2, self)
        print("Result from callback :\(result) value of c:\(self.c)")
        print("END DoSomethingCbPassNonEscaping")
    }
    
    public mutating func doSomethingcbpassMutInoutNonEscaping(_ printmemory: Bool, callBack: CallbackPassArgInout) {
        print("START doSomethingcbpassMutInoutNonEscaping")
        self.c += 1
        if printmemory {
            self.PrintAddress()
            self.memory.PrintStructAddress()
        }
        let result = callBack(2, &self)
        print("Result from callback :\(result) value of c:\(self.c)")
        print("END doSomethingcbpassMutInoutNonEscaping")
    }
    
    public mutating func doSomeNestedMut() -> UInt8 {
        return 8
    }
}
