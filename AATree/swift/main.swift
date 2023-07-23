import Foundation

class AATree<T:Comparable> {
    let key: T
    var left: AATree<T>?
    var right: AATree<T>?
    var level: Int = 1

    init(key: T) {
        self.key = key
    }
}

func skew<T>(tree: AATree<T>?) -> AATree<T>? {
    guard let t = tree else {
    return nil
}

    guard let left = t.left else {
    return t
}

    // Red node to the left? Do a right rotation.
    if (left.level == t.level) {
        let l = left
        t.left = l.right
        l.right = t
        return l
    }

    return t
}

func split<T>(tree: AATree<T>?) -> AATree<T>? {
    guard let t = tree else {
    return nil
}

    guard let right = t.right else {
    return t
}

    guard let rightRight = right.right else {
    return t
}

    // Right-right red chain? Do a left rotation
    if (rightRight.level == t.level) {
        let l = right
        t.right = l.left
        l.left = t
        l.level += 1
        return l
    }

    return t
}

func insert<T>(tree: AATree<T>?, key: T) -> AATree<T>? {
    guard let t = tree else {
    return AATree<T>(key: key)
}

    if (key < t.key) {
        t.left = insert(tree: t.left, key: key)
    } else {
        t.right = insert(tree: t.right, key: key)
    }

    let skewed = skew(tree: t)
    return split(tree: skewed)
}

func display<T>(tree: AATree<T>?, space: String) {
    guard let t = tree else {
        return
}

    display(tree: t.left, space: space + "  ")

    print("\(space)\(t.key)")

    display(tree: t.right, space: space + "  ")
}

let fileName = CommandLine.arguments[1]
let numbers = try String(contentsOfFile: fileName)

var t: AATree<Int>?;

for number in numbers.components(separatedBy: " ") {
    let stripped = number.trimmingCharacters(in: .whitespacesAndNewlines)
    guard let n = Int(stripped) else {
    print("Failed to convert \(stripped) to Int.")
    exit(1)
}

    t = insert(tree: t, key: n);
}

display(tree: t, space: "");
