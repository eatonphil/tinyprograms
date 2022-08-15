use std::env;
use std::fs;
use std::io::{self, Read};

struct AATree<K: Ord> {
    key: K,
    left: Option<Box<AATree<K>>>,
    right: Option<Box<AATree<K>>>,
    level: i64,
}

fn skew<K: Ord>(tree: Option<Box<AATree<K>>>) -> Option<Box<AATree<K>>> {
    if tree.is_none() || tree.unwrap().left.is_none() {
        return tree;
    }

    if tree.unwrap().level == tree.unwrap().left.unwrap().level {
        let l = tree.unwrap();
        tree.unwrap().left = l.right;
        l.right = tree;
        return Some(l);
    }

    return tree;
}

fn split<K: Ord>(tree: &mut Option<Box<AATree<K>>>) -> Option<Box<AATree<K>>> {
    match tree {
        Some(t) => {
            match &t.right {
                Some(tr) => match tr.right {
                    Some(trr) => {
                        if trr.level == t.level {
                            t.right = tr.left;
                            tr.left = *tree;
                            tr.level += 1;
                            return Some(*tr);
                        }
                    }
                    _ => {}
                },
                _ => {}
            };
        }
        _ => {}
    };

    return *tree;
}

fn insert<K: Ord>(tree: Option<Box<AATree<K>>>, key: K) -> Option<Box<AATree<K>>> {
    if let Some(mut t) = tree {
        if key < t.key {
            t.left = insert(t.left, key)
        } else {
            t.right = insert(t.right, key)
        }

        let mut skewed = skew(Some(t));
        return split(&mut skewed);
    }

    return Some(Box::new(AATree {
        key: key,
        left: None,
        right: None,
        level: 1,
    }));
}

fn main() {
    let args: Vec<String> = env::args().collect();
    let filename = &args[1];

    let numbers: Vec<char> = fs::read_to_string(filename)
        .expect("Could not read file")
        .chars()
        .collect();
}
