package main

import (
	"fmt"
	"os"
	"strconv"
)

type Ordered interface {
	~int
}

type AATree[K Ordered] struct{
	key K
	left *AATree[K]
	right *AATree[K]
	level int
}

func skew[K Ordered](tree *AATree[K]) *AATree[K] {
	if tree == nil || tree.left == nil {
		return tree
	}

	if tree.left.level == tree.level {
		l := tree.left
		tree.left = l.right
		l.right = tree
		return l
	}

	return tree
}

func split[K Ordered](tree *AATree[K]) *AATree[K] {
	if tree == nil || tree.right == nil || tree.right.right == nil {
		return tree
	}

	if tree.right.right.level == tree.level {
		l := tree.right
		tree.right = l.left
		l.left = tree
		l.level++
		return l
	}

	return tree
}

func insert[K Ordered](tree *AATree[K], key K) *AATree[K] {
	if tree == nil {
		return &AATree[K]{
			key: key,
			left: nil,
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

func print[K Ordered](tree *AATree[K], space string) {
	if tree.left != nil {
		print(tree.left, space + "  ")
	}

	fmt.Printf("%s%v\n", space, tree.key)

	if tree.right != nil {
		print(tree.right, space + "  ")
	}
}

func splitNumbersFromFile(file string) []int {
	bytes, err := os.ReadFile(file)
	if err != nil {
		panic(err)
	}

	var tmp []byte
	var list []int

	for _, b := range bytes {
		if b == ' ' {
			i, err := strconv.Atoi(string(tmp))
			if err != nil {
				panic(err)
			}

			list = append(list, i)
			tmp = nil
			continue
		}

		if b == '\n' {
			continue
		}

		tmp = append(tmp, b)
	}

	if len(tmp) > 0 {
		i, err := strconv.Atoi(string(tmp))
		if err != nil {
			panic(err)
		}

		list = append(list, i)
	}

	return list
}

func main() {
	var t *AATree[int]
	for _, number := range splitNumbersFromFile(os.Args[1]) {
		t = insert(t, number)
	}

	print(t, "")
}
