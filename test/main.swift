public struct Memory<AddressSize> where AddressSize : BinaryInteger {
    private var buffer : [UInt8]

    public init(sizeInBytes: Int) {
        buffer = Array(repeating: 0, count: sizeInBytes)
    }
}

struct footester {
    public typealias PortReadCallback = (UInt16) -> UInt8
    public typealias PortReadCallbackPass = (UInt16, footester) -> UInt8
    public typealias PortReadCallbackPassInout = (UInt16, inout footester) -> UInt8
    
    public var memory: Memory<UInt16>
    public var c: Int32
    
    private var readcallback: PortReadCallbackPassInout
    
    public init(memory: Memory<UInt16>, _ foo: @escaping PortReadCallbackPassInout)
    {
        self.memory = memory
        self.readcallback = foo
        c = 1
    }
    
    public mutating func doSomethingMut(portRead: PortReadCallback) {
       var result = doSomeNestedMut()
        print(result)
    }

    public func doSomethingcb(portRead: PortReadCallback) {
       var result = portRead(2)
        print(result)
    }

    public mutating func doSomethingmutcbcaptureglobal(portRead: PortReadCallback) {
       var result = portRead(2)
        print(result)
    }
    
//    public mutating func doSomethingmutcbcaptureglobalEscaping() {
//       var result = self.readcallback(2)
//        print(result)
//    }
    
    public mutating func doSomethingmutcbcaptureInOutEscaping() {
        var result = self.readcallback(2, &self)
        print(result)
        //TODO verify state is updated in global
    }

    public func doSomethingcbpass(portRead: PortReadCallbackPass) {
       var result = portRead(2, self)
        print(result)
    }

    public mutating func doSomethingcbpassMut(portRead: PortReadCallbackPass) {
       var result = portRead(2, self)
        print(result)
        //TODO: verify array address for memory is the same
    }

    public mutating func doSomethingcbpassMutInout(portRead: PortReadCallbackPassInout) {
       var result = portRead(2, &self)
        print(result)
    }

    public mutating func doSomeNestedMut() -> UInt8 {
return 8
    }
}

func portRead(_ port: UInt16) -> UInt8 {
    switch ft.c {
        case 2:
            return 0
        case 9:

            return 0
        default:
            return 0
    }
    return 0
}

func portReadPass(_ port: UInt16, _ inst: footester) -> UInt8 {
    switch inst.c {
        case 2:
            return 0
        case 9:

            return 0
        default:
            return 0
    }
}

func portReadPassInOut(_ port: UInt16, _ inst: inout footester) -> UInt8 {
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

var ft: footester = footester(memory: Memory(sizeInBytes: 65536), portReadPassInOut)
ft.c=9
//ft.doSomething(portRead: portRead)
//ft.doSomethingmutcbcaptureglobal(portRead: portRead)
//ft.doSomethingmutcbcaptureglobalEscaping(portRead: portRead)
//ft.doSomethingmutcbcaptureInOutEscaping()
//ft.doSomethingcbpass(portRead: portReadPass)
//ft.doSomethingcbpassMut(portRead: portReadPass)
ft.doSomethingcbpassMutInout(portRead: portReadPassInOut)
print("done \(ft.c)")
