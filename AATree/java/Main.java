import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;

class AATree<T extends Comparable<T>> {
  T key;
  AATree<T> left;
  AATree<T> right;
  int level;

  AATree(T key) {
    this.key = key;
    this.level = 1;
    this.left = null;
    this.right = null;
  }

  static <T extends Comparable<T>> AATree<T> skew(AATree<T> tree) {
    if (tree == null || tree.left == null) {
      return tree;
    }

    // Red node to the left? Do a right rotation.
    if (tree.left.level == tree.level) {
      AATree<T> l = tree.left;
      tree.left = l.right;
      l.right = tree;
      return l;
    }

    return tree;
  }

  static <T extends Comparable<T>> AATree<T> split(AATree<T> tree) {
    if (tree == null || tree.right == null || tree.right.right == null) {
      return tree;
    }

    // Right-right red chain? Do a left rotation
    if (tree.right.right.level == tree.level) {
      AATree<T> l = tree.right;
      tree.right = l.left;
      l.left = tree;
      l.level++;
      return l;
    }

    return tree;
  }

  static <T extends Comparable<T>> AATree<T> insert(AATree<T> tree, T key) {
    if (tree == null) {
      return new AATree<T>(key);
    }

    if (key.compareTo(tree.key) < 0) {
      tree.left = insert(tree.left, key);
    } else {
      tree.right = insert(tree.right, key);
    }

    return split(skew(tree));
  }

  static <T extends Comparable<T>> void display(AATree<T> tree, String space) {
    if (tree == null) {
      return;
    }

    display(tree.left, space + "  ");

    System.out.printf("%s%s\n", space, tree.key.toString());

    display(tree.right, space + "  ");
  }
}

public class Main {
  public static void main(final String[] args) throws IOException {
    if (args.length < 1) {
      System.out.println("Expected file name to interpret");
      return;
    }

    String prog = Files.readString(Path.of(args[0]), StandardCharsets.US_ASCII);
    AATree<Integer> t = null;

    for (String number : prog.split(" ")) {
      Integer n = Integer.parseInt(number.trim());
      t = AATree.<Integer>insert(t, n);
    }

    AATree.<Integer>display(t, "");
  }
}
