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

print("Welcome to memory exclusivity tester!")
print("To run all examples, compile with swiftc -enforce-exclusivity=checked") // TODO: replace with lldb script

// // // //
// Problem
// // // //

var ft: ExclusivityTester = ExclusivityTester(memory: Memory(sizeInBytes: 65536), TestCBPassArg, TestCBPassArgInOut, TestCBCaptureGlobal)
// TODO: init a new ET for every
// TODO: does begin/end breakpoint fire? lldb
ft.c=9

//Fail when built via swiftc -enforce-exclusivity=checked
// use swiftc -enforce-exclusivity=unchecked
// swiftc main.swift exclusivitytester.swift -DBUILD_FAILING to define macro
#if BUILD_FAILING
ft.doSomethingmutcbcaptureglobalEscaping()
#endif

print("\n")

// // // // //
// Try 1: wrap instance and callback in stuct/ class in this file
// TODO: build wrapped version
// // // //

class wrappedtester {
    private let et: ExclusivityTester
    init() {
        et = ExclusivityTester(memory: Memory(sizeInBytes: 65536))
            //TODO: assign closures
    }

    func TestCBPassArgInOutWrapperMember(_ port: UInt16, _ inst: inout ExclusivityTester) -> UInt8 {
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

}

let wt = wrappedtester()
//let result = wt.TestCBCaptureWrapperMember(5)


// Try 2: non-escaping
//Fail when built via swiftc -enforce-exclusivity=checked
// use swiftc -enforce-exclusivity=unchecked
// swiftc main.swift exclusivitytester.swift -DBUILD_FAILING
#if BUILD_FAILING
ft.doSomethingmutcbcaptureglobalNonEscaping(callBack: TestCBCaptureGlobal)
#endif

print("\n")

// Try 3 remove global from callback non escaping
ft.DoSomethingCbPassNonEscaping(callBack: TestCBPassArg)

print("\n")

ft.DoSomethingMutCbPassArgNonEscaping(printmemory: false, callBack: TestCBPassArg)

print("\n")

ft.doSomethingcbpassMutInoutNonEscaping(false) {
    cc, dd -> UInt8 in
    print(cc)
    dd.c += 1000
    return 10
}

print("\n")

// Does it work escaping?  Minimize code change
ft.doSomethingmutcbPassArgInOutEscaping()

print("\n")

// Apply fix.. InOut not compatible with real problem
// Because it requires mutability to propogate so:

ft.DoSomethingMutCbPassArgEscaping(false)

print("\n")
print("*************")

// Does the fact it works escaping mean the docs are wrong?
// And.. above works but what about implications of memory?

// Do some basic tests on memory
print ("Memory locations for first instance")
ft.PrintAddress()
ft.memory.PrintStructAddress()

print ("Assignment of struct to another variable results in a copy (no copy on write for structs)")
var bt = ft
bt.PrintAddress()
print ("But we do get Copy-on-write behavior for the memory buffer wrapped by memory struct")
bt.memory.PrintStructAddress()

print ("Modify BT memory")
bt.memory.SetAddress(10, 10)
bt.memory.PrintStructAddress()

print()

print ("Re-run by-value version, printing memory")
// Re-run by value version, printing memory
ft.PrintAddress()
ft.memory.PrintBufferAddress()
ft.DoSomethingMutCbPassArgNonEscaping(printmemory: true) {
    aa, bb -> UInt8 in
    print("Memory in callback")
    //bb.PrintAddress() // Can't as bb is not passed as inout
    // TODO: how to use LLDB to verify deep copy
    print("Can't print memory as instance passed is not inout")
    print("callback end")
    return 0
}

print()

print ("Re-run inout version, printing memory")
// Re-run by value version, printing memory
ft.doSomethingcbpassMutInoutNonEscaping(true) {
    aa, bb -> UInt8 in
    print("Memory in callback")
    bb.PrintAddress()
    bb.memory.PrintBufferAddress()
    print("callback end")
    return 0
}

// Conclusion.  Remove global capture.  Pass inout to avoid deep copy

print("done \(ft.c)")
