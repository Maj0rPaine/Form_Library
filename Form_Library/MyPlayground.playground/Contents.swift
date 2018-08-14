//: Playground - noun: a place where people can play

import UIKit

var num1: Int = 1
var char1: Character = "a"

func changeNumber(num: Int) {
    var mutableNum = num
    mutableNum = 2
    print(mutableNum) // 2
    print(num1) // 1
}

changeNumber(num: num1)

func changeChar(char: inout Character) {
    char = "b"
    print(char) // b
    print(char1) // b
}

changeChar(char: &char1)
