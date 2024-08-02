import Cocoa

let numberOfItem = 10

let queue = DispatchQueue(label: "Greeter", qos: .background)

for i in 0..<numberOfItem {
    queue.async {
        print("Executing item \(i)")
    }
}

queue.sync {
    print("Goodbye")
}

print("Exit")
