import std.file: readText;
import std.stdio: writeln;
import std.format;
import std.array: split;
import std.conv: to;

struct AATree(T) {
  T key;
  AATree!(T)* left;
  AATree!(T)* right;
  int level;
};

AATree!(T)* skew(T)(AATree!(T)* tree) {
  if ( tree == null || tree.left == null ){
    return tree;
  }

  // Red node to the left? Do a right rotation.
  if (tree.left.level == tree.level) {
    AATree!(T)* l = tree.left;
    tree.left = l.right;
    l.right = tree;
    return l;
  }
  
  return tree;
}

AATree!(T)* split(T)(AATree!(T)* tree) {
  if (tree == null || tree.right == null || tree.right.right == null) {
    return tree;
  }

  // Right-right red chain? Do a left rotation
  if (tree.right.right.level == tree.level) {
    AATree!(T)* l = tree.right;
    tree.right = l.left;
    l.left = tree;
    l.level++;
    return l;
  }

  return tree;
}

AATree!(T)* insert(T)(AATree!(T)* tree, T key) {
  if (tree == null) {
    return new AATree!(T)(key, null, null, 1);
  }

  if (key < tree.key) {
    tree.left = insert(tree.left, key);
  } else {
    tree.right = insert(tree.right, key);
  }

  return split(skew(tree));
}

void print(T)(AATree!(T)* tree, string space) {
  if (tree.left != null) {
    print(tree.left, space~"  ");
  }

  writeln(format("%s%s", space, tree.key));

  if (tree.right != null) {
    print(tree.right, space~"  ");
  }
}

void main(string[] args) {
  string numbers = readText(args[1]);

  AATree!(int)* t;
  foreach (number; numbers.split) {
    t = insert(t, number.to!(int));
  }

  print(t, "");
}
