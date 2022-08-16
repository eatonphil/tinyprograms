use std::env;
use std::fs;

struct AATree<K: Ord + std::fmt::Display> {
    key: K,
    left: Option<Box<AATree<K>>>,
    right: Option<Box<AATree<K>>>,
    level: i64,
}

fn skew<K: Ord + std::fmt::Display>(mut tree: Option<Box<AATree<K>>>) -> Option<Box<AATree<K>>> {
    if let Some(mut root) = tree.as_mut() {
        if Some(root.level) == root.left.as_ref().map(|l| l.level) {
            // Unwrap is safe if we pass the level condition check
            let mut left = root.left.take().unwrap();
            root.left = left.right.take();
            left.right = tree;

            return Some(left);
        }
    }

    tree
}

fn split<K: Ord + std::fmt::Display>(mut tree: Option<Box<AATree<K>>>) -> Option<Box<AATree<K>>> {
    if let Some(mut root) = tree.as_mut() {
        if Some(root.level)
            == root
            .right
            .as_ref()
            .and_then(|r| r.right.as_ref().map(|rr| rr.level))
        {
            // Unwrap is safe if we pass the level condition check
            let mut right = root.right.take().unwrap();
            root.right = right.left.take();
            right.left = tree;
            right.level += 1;

            return Some(right);
        }
    }

    tree
}

fn insert<K: Ord + std::fmt::Display>(tree: Option<Box<AATree<K>>>, key: K) -> Option<Box<AATree<K>>> {
    if let Some(mut t) = tree {
        if key < t.key {
            t.left = insert(t.left, key)
        } else {
            t.right = insert(t.right, key)
        }

        let skewed = skew(Some(t));
        return split(skewed);
    }

    Some(Box::new(AATree {
        key,
        left: None,
        right: None,
        level: 1,
    }))
}

fn print<K: Ord + std::fmt::Display>(tree: Option<Box<AATree<K>>>, space: &str) {
    let next_space = &(space.to_owned()+"  ");
    if let Some(t) = tree {
	if t.left.is_some() {
	    print(t.left, next_space);
	}

	print!("{}{}\n", space, t.key);

	if t.right.is_some() {
	    print(t.right, next_space);
	}
    }
}

fn main() {
    let args: Vec<String> = env::args().collect();
    let filename = &args[1];

    let numbers: Vec<i64> = fs::read_to_string(filename)
        .expect("Could not read file")
	.split_whitespace()
	.map(|number| number.parse::<i64>().unwrap())
	.collect();

    let mut t: Option<Box<AATree<i64>>> = None;
    for n in numbers {
	t = insert(t, n);
    }

    print(t, "");
}
