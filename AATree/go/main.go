package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"
)

type Comparable interface {
	~int | ~uint
}

type AATree[K Comparable] struct {
	key   K
	left  *AATree[K]
	right *AATree[K]
	level int
}

func skew[K Comparable](tree *AATree[K]) *AATree[K] {
	if tree == nil || tree.left == nil {
		return tree
	}

	// Red node to the left? Do a right rotation.
	if tree.left.level == tree.level {
		l := tree.left
		tree.left = l.right
		l.right = tree
		return l
	}

	return tree
}

func split[K Comparable](tree *AATree[K]) *AATree[K] {
	if tree == nil || tree.right == nil || tree.right.right == nil {
		return tree
	}

	// Right-right red chain? Do a left rotation
	if tree.right.right.level == tree.level {
		l := tree.right
		tree.right = l.left
		l.left = tree
		l.level++
		return l
	}

	return tree
}

func insert[K Comparable](tree *AATree[K], key K) *AATree[K] {
	if tree == nil {
		return &AATree[K]{
			key:   key,
			left:  nil,
			right: nil,
			level: 1,
		}
	}

	if key < tree.key {
		tree.left = insert(tree.left, key)
	} else {
		tree.right = insert(tree.right, key)
	}

	return split(skew(tree))
}

func print[K Comparable](tree *AATree[K], space string) {
	if tree.left != nil {
		print(tree.left, space+"  ")
	}

	fmt.Printf("%s%v\n", space, tree.key)

	if tree.right != nil {
		print(tree.right, space+"  ")
	}
}

func main() {
	bytes, err := os.ReadFile(os.Args[1])
	if err != nil {
		panic(err)
	}

	numbers := strings.Fields(string(bytes))
	
	var t *AATree[int]
	for _, number := range numbers {
		i, err := strconv.Atoi(number)
		if err != nil {
			panic(err)
		}

		t = insert(t, i)
	}

	print(t, "")
}
