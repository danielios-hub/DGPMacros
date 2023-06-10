import DGPMacros

@Init
class Person {
    let name: String
    let age: Int
    var gender: String
}

@Init(isPublic: false)
class PrivatePerson {
    let name: String
    let age: Int
    var gender: String
}

@Init
struct StructuredPerson {
    let name: String
    let age: Int
    var gender: String
}

let person = Person(name: "name", age: 2, gender: "M")
