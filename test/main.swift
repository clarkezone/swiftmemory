public struct Memory<AddressSize> where AddressSize : BinaryInteger {
    private var buffer : [UInt8]

    public init(sizeInBytes: Int) {
        buffer = Array(repeating: 0, count: sizeInBytes)
    }
}

struct footester {
    public typealias PortReadCallback = (UInt16) -> UInt8
    public typealias PortWriteCallback = (UInt16, UInt8) -> ()
    
    public var memory: Memory<UInt16>
    public var c: Int32
    public init(memory: Memory<UInt16>)
    {
        self.memory = memory
        c = 1
    }
    
    public mutating func doSomething(portRead: PortReadCallback,
                            portWrite: PortWriteCallback) {
        var result = portRead(2)
        print(result)
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

func portWrite(_ addr: UInt16, _ value: UInt8) {
   
}

// The Swift Programming Language
// https://docs.swift.org/swift-book

print("Hello, world!")

var ft: footester = footester(memory: Memory(sizeInBytes: 65536))
ft.c=9
ft.doSomething(portRead: portRead, portWrite: portWrite)
print("done")
