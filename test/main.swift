import Foundation

func address(o: UnsafeRawPointer) -> Int {
    return Int(Int(bitPattern: o))
}

public struct Memory<AddressSize> where AddressSize : BinaryInteger {
    private var buffer : [AddressSize]

    public init(sizeInBytes: Int) {
        buffer = Array(repeating: 0, count: sizeInBytes)
    }

    public func PrintAddress () {
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
    
    public mutating func doSomethingmutcbPassArgEscaping() {
        self.c += 1
       let result = self.CallbackPassArg(2, self)
        print(result)
    }
    
    public mutating func doSomethingmutcbPassArgInOutEscaping() {
        self.c += 1
        let result = self.CallbackPassArgInout(2, &self)
        print(result)
    }

    public func doSomethingcbpassNonEscaping(callBack: CallbackPassArg) {
        let result = callBack(2, self)
        print(result)
    }

    public mutating func doSomethingcbpassMutNonEscaping(callBack: CallbackPassArg) {
        self.c += 1
       self.PrintAddress()
       let result = callBack(2, self)
        print(result)
       self.memory.PrintAddress()
       //TODO: verify array address for memory is the same
    }

    public mutating func doSomethingcbpassMutInoutNonEscaping(callBack: CallbackPassArgInout) {
        self.c += 1
        //TODO: callback mutates because of inout
       let result = callBack(2, &self)
        print(result)
    }

    public mutating func doSomeNestedMut() -> UInt8 {
return 8
    }
}

// Callbacks

func TestCBCaptureGlobal(_ port: UInt16) -> UInt8 {
    switch ft.c {
        case 2:
            return 0
        case 9:

            return 0
        default:
            return 0
    }
}

func TestCBPassArg(_ port: UInt16, _ inst: ExclusivityTester) -> UInt8 {
    switch inst.c {
        case 2:
            return 0
        case 9:
            return 0
        default:
            return 0
    }
}

func TestCBPassArgInOut(_ port: UInt16, _ inst: inout ExclusivityTester) -> UInt8 {
    inst.c = 100
    switch inst.c {
        case 2:
            return 0
        case 9:
            return 0
        default:
            return 0
    }
}

print("Hello, world!")

var ft: ExclusivityTester = ExclusivityTester(memory: Memory(sizeInBytes: 65536), TestCBPassArg, TestCBPassArgInOut, TestCBCaptureGlobal)
ft.c=9
ft.PrintAddress()
ft.memory.PrintAddress()

//Fail when built via swiftc -enforce-exclusivity=checked
// use swiftc -enforce-exclusivity=unchecked
ft.doSomethingmutcbcaptureglobalEscaping()

//Fail when built via swiftc -enforce-exclusivity=checked
// use swiftc -enforce-exclusivity=unchecked
ft.doSomethingmutcbcaptureglobalNonEscaping(callBack: TestCBCaptureGlobal)

print("START doSomethingmutcbPassArgEscaping")
ft.doSomethingmutcbPassArgEscaping()
print("END doSomethingmutcbPassArgEscaping")

print("START doSomethingmutcbPassArgInOutEscaping")
ft.doSomethingmutcbPassArgInOutEscaping()
print("END doSomethingmutcbPassArgInOutEscaping")

print("START doSomethingcbpassNonEscaping")
ft.doSomethingcbpassNonEscaping(callBack: TestCBPassArg)
print("END doSomethingcbpassNonEscaping")

print("START doSomethingcbpassMutNonEscaping")
ft.doSomethingcbpassMutNonEscaping(callBack: TestCBPassArg)
print("END doSomethingcbpassMutNonEscaping")

print("START doSomethingcbpassMutNonEscaping")
ft.doSomethingcbpassMutInoutNonEscaping(callBack: TestCBPassArgInOut)
print("END doSomethingcbpassMutNonEscaping")


print ("Copy but not modified")
var bt = ft
bt.PrintAddress()

print ("Modify BT")
bt.c=10
bt.PrintAddress()

print("done \(ft.c)")
