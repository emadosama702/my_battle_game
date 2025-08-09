import 'dart:collection';
import 'package:flame/components.dart';

class Node {
  final Vector2 position;
  double gCost = double.infinity; // cost from start to current
  double hCost = 0; // heuristic cost to end
  double get fCost => gCost + hCost;
  Node? parent;

  Node(this.position);
}

class Pathfinding {
  List<Node> findPath(Vector2 start, Vector2 end, List<List<int>> grid) {
    final startNode = Node(start);
    final endNode = Node(end);

    final openSet = PriorityQueue<Node>((a, b) => a.fCost.compareTo(b.fCost));
    final closedSet = <Node>[];

    startNode.gCost = 0;
    startNode.hCost = _heuristic(startNode.position, endNode.position);
    openSet.add(startNode);

    while (openSet.isNotEmpty) {
      final currentNode = openSet.removeFirst();
      closedSet.add(currentNode);

      if (_isSamePosition(currentNode.position, endNode.position)) {
        return _retracePath(startNode, currentNode);
      }

      for (final neighborPos in _getNeighbors(currentNode.position, grid)) {
        if (closedSet.any((n) => _isSamePosition(n.position, neighborPos))) {
          continue;
        }

        final tentativeGCost = currentNode.gCost + _distance(currentNode.position, neighborPos);
        final neighborNode = Node(neighborPos);
        neighborNode.gCost = tentativeGCost;
        neighborNode.hCost = _heuristic(neighborPos, endNode.position);
        neighborNode.parent = currentNode;

        final openNode = openSet.firstWhere(
          (n) => _isSamePosition(n.position, neighborPos),
          orElse: () => Node(Vector2(-1, -1)),
        );

        if (openNode.position.x == -1 && openNode.position.y == -1) {
          openSet.add(neighborNode);
        } else if (tentativeGCost < openNode.gCost) {
          openNode.gCost = tentativeGCost;
          openNode.parent = currentNode;
        }
      }
    }
    return []; // no path found
  }

  List<Vector2> _retracePath(Node startNode, Node endNode) {
    final path = <Vector2>[];
    var currentNode = endNode;
    while (!_isSamePosition(currentNode.position, startNode.position)) {
      path.add(currentNode.position);
      currentNode = currentNode.parent!;
    }
    path.add(startNode.position);
    return path.reversed.toList();
  }

  double _heuristic(Vector2 a, Vector2 b) {
    return (a - b).length;
  }

  double _distance(Vector2 a, Vector2 b) {
    return (a - b).length;
  }

  bool _isSamePosition(Vector2 a, Vector2 b) {
    return a.x == b.x && a.y == b.y;
  }

  List<Vector2> _getNeighbors(Vector2 pos, List<List<int>> grid) {
    final neighbors = <Vector2>[];
    final directions = [
      Vector2(0, -1),
      Vector2(1, 0),
      Vector2(0, 1),
      Vector2(-1, 0),
    ];
    for (final dir in directions) {
      final newPos = pos + dir;
      if (_isValidPosition(newPos, grid)) {
        neighbors.add(newPos);
      }
    }
    return neighbors;
  }

  bool _isValidPosition(Vector2 pos, List<List<int>> grid) {
    final x = pos.x.toInt();
    final y = pos.y.toInt();
    return x >= 0 && x < grid[0].length && y >= 0 && y < grid.length && grid[y][x] == 0;
  }
}
