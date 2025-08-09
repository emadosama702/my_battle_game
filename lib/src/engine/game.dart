// lib/src/engine/game.dart
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

/// Main game class — contains Player, Enemy (AI), and simple "combat" logic.
/// Exposes methods used by the HUD overlay:
/// - movePlayer(Vector2 dir)    -> direction vector with components in [-1,1]
/// - basicAttack()              -> player basic attack
/// - useSkill(int idx)         -> use player skill 1..3
/// - double getPlayerHp()       -> 0..1
/// - double getEnemyHp()        -> 0..1
/// - double getCharge()         -> 0..1
class MyBattleGame extends FlameGame with HasDraggables, HasTappables {
  late Player player;
  late Enemy enemy;

  // world size used for camera / layout
  final Vector2 worldSize = Vector2(800, 1200);

  // simple lists for projectiles/effects if needed later
  final List<Projectile> projectiles = [];

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    camera.viewport = FixedResolutionViewport(Vector2(800, 1200));

    // background (solid color)
    add(RectangleComponent(size: worldSize, paint: Paint()..color = const Color(0xFF0B0B12)));

    // spawn player and enemy
    player = Player(position: worldSize / 2 + Vector2(-120, 0));
    enemy = Enemy(position: worldSize / 2 + Vector2(120, 0), difficulty: EnemyDifficulty.hard);

    add(player);
    add(enemy);
  }

  @override
  void update(double dt) {
    super.update(dt);
    // update projectiles (basic) - iterate backwards to safely remove elements
    for (int i = projectiles.length - 1; i >= 0; i--) {
      final p = projectiles[i];
      p.update(dt);
      if (p.shouldRemove) {
        p.removeFromParent();
        projectiles.removeAt(i);
      }
    }
  }

  // -------------------------
  // Methods called by HUD
  // -------------------------
  /// dir: Vector2 with x,y in [-1,1]; magnitude affects speed proportionally
  void movePlayer(Vector2 dir) {
    player.moveInput = dir.clampScalar(-1.0, 1.0);
  }

  void basicAttack() {
    player.basicAttack(enemy);
  }

  void useSkill(int idx) {
    player.useSkill(idx, enemy);
  }

  double getPlayerHp() => player.hp / player.maxHp;

  double getEnemyHp() => enemy.hp / enemy.maxHp;

  double getCharge() => player.charge / player.chargeMax;

  // helper for game to spawn a projectile if later used
  void spawnProjectile(Projectile p) {
    add(p);
    projectiles.add(p);
  }
}

// -------------------------
// Player component
// -------------------------
class Player extends PositionComponent {
  double maxHp = 100;
  double hp = 100;
  double speed = 220; // pixels per second
  Vector2 velocity = Vector2.zero();

  // input
  Vector2 moveInput = Vector2.zero();

  // charge for ulti
  double charge = 0;
  double chargeMax = 100;

  // cooldowns in seconds
  Map<int, double> skillCooldown = {1: 0, 2: 0, 3: 0};
  double basicCooldown = 0.2;
  double basicCooldownTimer = 0;

  // skill definitions (tunable)
  final Map<int, Skill> skills = {
    1: Skill(damage: 10, cooldown: 2.5, range: 80),
    2: Skill(damage: 18, cooldown: 4.0, range: 120),
    3: Skill(damage: 28, cooldown: 6.0, range: 150),
  };

  // ulti flag
  bool ultiReady = false;
  double ultiRange = 60;

  Player({required Vector2 position}) {
    this.position = position;
    size = Vector2(64, 64);
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // simple visual: colored square
    add(RectangleComponent(size: size, paint: Paint()..color = Colors.green, anchor: Anchor.center));
  }

  @override
  void update(double dt) {
    super.update(dt);

    // movement
    if (moveInput.length > 0) {
      velocity = moveInput.normalised() * (speed * moveInput.length);
    } else {
      velocity = Vector2.zero();
    }
    position += velocity * dt;

    // clamp inside world bounds
    position.clamp(Vector2(40, 200), Vector2(760, 1000));

    // cooldown timers
    basicCooldownTimer = (basicCooldownTimer - dt).clamp(0, double.infinity);
    skillCooldown.updateAll((key, value) => (value - dt).clamp(0.0, double.infinity));

    // charge fills slowly and on dealing damage
    charge = (charge + 8 * dt).clamp(0, chargeMax);
    ultiReady = charge >= chargeMax;
  }

  void receiveDamage(double dmg) {
    hp = (hp - dmg).clamp(0, maxHp);
    // on damage maybe gain small charge (counterplay)
    charge = (charge + dmg * 0.2).clamp(0, chargeMax);
    // ensure ultiReady is updated after charge change
    ultiReady = charge >= chargeMax;
  }

  // Basic attack: instant melee check
  void basicAttack(Enemy target) {
    if (basicCooldownTimer > 0) return;
    basicCooldownTimer = basicCooldown;
    final dist = position.distanceTo(target.position);
    if (dist <= 70) {
      target.receiveDamage(8);
      charge = (charge + 5).clamp(0, chargeMax);
    }
  }

  void useSkill(int idx, Enemy target) {
    if (!skills.containsKey(idx)) return;
    final s = skills[idx]!;
    if (skillCooldown[idx]! > 0) return;
    final dist = position.distanceTo(target.position);
    if (dist <= s.range) {
      // apply damage and effects
      target.receiveDamage(s.damage);
      charge = (charge + s.damage * 0.6).clamp(0, chargeMax);
      skillCooldown[idx] = s.cooldown;
    } else {
      // if out of range, do a dash toward enemy and still apply partial?
      // simple: dash + no damage
      final dir = (target.position - position).normalized();
      position += dir * 24;
      skillCooldown[idx] = s.cooldown;
    }
  }

  // Ulti (finish): instant kill if close enough and ultiReady true
  bool tryUseUlti(Enemy target) {
    if (!ultiReady) return false;
    final dist = position.distanceTo(target.position);
    if (dist <= ultiRange) {
      // perform finish move
      target.receiveDamage(9999); // guaranteed kill
      charge = 0;
      ultiReady = false;
      return true;
    }
    return false;
  }
}

// simple skill struct
class Skill {
  final double damage;
  final double cooldown;
  final double range;
  Skill({required this.damage, required this.cooldown, required this.range});
}

// -------------------------
// Enemy & AI
// -------------------------
enum EnemyState { idle, chase, attack, dodge, useUlti, retreat }

enum EnemyDifficulty { easy, medium, hard }

class Enemy extends PositionComponent {
  double maxHp = 140;
  double hp = 140;
  double speed = 190;
  Vector2 velocity = Vector2.zero();
  EnemyState state = EnemyState.idle;

  // internal timers
  double stateTimer = 0;
  double attackCooldown = 0;
  double dodgeCooldown = 0;

  // charge system like player (for ulti)
  double charge = 0;
  double chargeMax = 100;
  bool ultiReady = false;
  double ultiRange = 70;

  // difficulty parameters
  final EnemyDifficulty difficulty;

  // reference to player (set by parent game when needed)
  Player? playerRef;

  Enemy({required Vector2 position, this.difficulty = EnemyDifficulty.medium}) {
    this.position = position;
    size = Vector2(64, 64);
    anchor = Anchor.center;
    if (difficulty == EnemyDifficulty.hard) {
      maxHp = 180;
      hp = 180;
      speed = 220;
    } else if (difficulty == EnemyDifficulty.medium) {
      maxHp = 150;
      hp = 150;
      speed = 200;
    }
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    add(RectangleComponent(size: size, paint: Paint()..color = Colors.red, anchor: Anchor.center));
    // attempt to find player from the parent (game) later - will be assigned by game after both added
  }

  @override
  void onMount() {
    super.onMount();
    // try to find player in the parent chain
    parent?.children.whereType<Player>().firstOrNull?.let((p) => playerRef = p);
  }

  @override
  void update(double dt) {
    super.update(dt);
    // try to acquire player if null
    if (playerRef == null) {
      parent?.children.whereType<Player>().firstOrNull?.let((p) => playerRef = p);
    }
    final p = playerRef;
    if (p == null) return;

    // fill charge gradually and based on events
    charge = (charge + 6 * dt).clamp(0, chargeMax);
    ultiReady = charge >= chargeMax;

    // simple FSM for hard AI
    switch (state) {
      case EnemyState.idle:
        _idleBehavior(dt, p);
        break;
      case EnemyState.chase:
        _chaseBehavior(dt, p);
        break;
      case EnemyState.attack:
        _attackBehavior(dt, p);
        break;
      case EnemyState.dodge:
        _dodgeBehavior(dt, p);
        break;
      case EnemyState.useUlti:
        _useUltiBehavior(dt, p);
        break;
      case EnemyState.retreat:
        _retreatBehavior(dt, p);
        break;
    }

    // cooldowns
    attackCooldown = (attackCooldown - dt).clamp(0, double.infinity);
    dodgeCooldown = (dodgeCooldown - dt).clamp(0, double.infinity);
    stateTimer = (stateTimer - dt).clamp(0, double.infinity);

    // limits and movement
    position += velocity * dt;
    position.clamp(Vector2(40, 200), Vector2(760, 1000));
  }

  void _idleBehavior(double dt, Player p) {
    // if player far, stay or do small patrol
    final dist = position.distanceTo(p.position);
    if (dist < 340) {
      state = EnemyState.chase;
      stateTimer = 0;
    } else {
      // slow patrol
      velocity = Vector2(sin(0.5 * dt), 0) * 10;
    }
  }

  void _chaseBehavior(double dt, Player p) {
    final dist = position.distanceTo(p.position);
    // predict player future pos -> interception (hard AI)
    final predicted = _predictPlayerPosition(p, 0.35);
    final dir = (predicted - position).normalized();
    velocity = dir * speed;

    // if in attack range -> attack
    if (dist <= 80 && attackCooldown <= 0) {
      state = EnemyState.attack;
      attackCooldown = 0.9; // small delay after attack
      stateTimer = 0.3;
    }

    // if near and ulti ready -> try use ulti
    if (ultiReady && dist <= ultiRange) {
      state = EnemyState.useUlti;
      stateTimer = 0.2;
    }

    // occasionally attempt dodge if player's velocity big (simple heuristic)
    if (dodgeCooldown <= 0 && p.velocity.length > 40 && dist < 160) {
      // 40% chance to dodge on hard
      final chance = difficulty == EnemyDifficulty.hard ? 0.4 : 0.15;
      if (Random().nextDouble() < chance) {
        state = EnemyState.dodge;
        dodgeCooldown = 1.8;
        stateTimer = 0.25;
      }
    }
  }

  void _attackBehavior(double dt, Player p) {
    // instant melee attack
    if (stateTimer <= 0) {
      // perform attack
      final dist = position.distanceTo(p.position);
      if (dist <= 90) {
        p.receiveDamage(12 + (difficulty == EnemyDifficulty.hard ? 6 : 0));
        // gain charge quickly when dealing damage
        charge = (charge + 12).clamp(0, chargeMax);
      }
      // after attacking, switch back to chase
      state = EnemyState.chase;
    } else {
      // small windup
      velocity = Vector2.zero();
    }
  }

  void _dodgeBehavior(double dt, Player p) {
    // simple perpendicular dodge to player's direction
    final dirToPlayer = (p.position - position).normalized();
    final perp = Vector2(-dirToPlayer.y, dirToPlayer.x);
    velocity = perp * (speed * 1.1);
    if (stateTimer <= 0) state = EnemyState.chase;
  }

  void _useUltiBehavior(double dt, Player p) {
    if (stateTimer <= 0) {
      // perform finish if in range
      final dist = position.distanceTo(p.position);
      if (dist <= ultiRange && ultiReady) {
        p.receiveDamage(9999); // kill player
        charge = 0;
        ultiReady = false;
      }
      state = EnemyState.chase;
    } else {
      velocity = Vector2.zero();
    }
  }

  void _retreatBehavior(double dt, Player p) {
    // retreat to safe distance if low HP
    final dir = (position - p.position).normalized();
    velocity = dir * speed;
    if (position.distanceTo(p.position) > 260) {
      state = EnemyState.chase;
    }
  }

  Vector2 _predictPlayerPosition(Player p, double lookaheadSeconds) {
    // predictive intercept: current player pos + velocity * t (limited)
    final predicted = p.position + p.velocity * lookaheadSeconds;
    // clamp inside arena
    return predicted.clamp(Vector2(40, 200), Vector2(760, 1000));
  }

  void receiveDamage(double dmg) {
    hp = (hp - dmg).clamp(0, maxHp);
    charge = (charge + dmg * 0.4).clamp(0, chargeMax);
    // ensure ultiReady is updated after charge change
    ultiReady = charge >= chargeMax;
    // if HP very low, try retreat on non-hard or on some chance
    if (hp / maxHp < 0.25 && difficulty != EnemyDifficulty.hard) {
      state = EnemyState.retreat;
    }
    // hard AI attempts counterplay: on damage, sometimes dodge immediately
    if (difficulty == EnemyDifficulty.hard && dodgeCooldown <= 0) {
      if (Random().nextDouble() < 0.45) {
        state = EnemyState.dodge;
        dodgeCooldown = 1.6;
        stateTimer = 0.22;
      }
    }
  }
}

// -------------------------
// Simple projectile placeholder (not used heavily here but ready)
// -------------------------
class Projectile extends PositionComponent {
  Vector2 velocity = Vector2.zero();
  double life = 2.0;
  bool shouldRemove = false;
  double damage = 8;

  Projectile({required Vector2 pos, required Vector2 vel, required this.damage}) {
    position = pos;
    velocity = vel;
    size = Vector2(12, 12);
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    add(RectangleComponent(size: size, paint: Paint()..color = Colors.yellow, anchor: Anchor.center));
  }

  void update(double dt) {
    life -= dt;
    if (life <= 0) shouldRemove = true;
    position += velocity * dt;
  }
}

// -------------------------
// Extensions / helpers
// -------------------------
extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}

extension _ClampVec on Vector2 {
  Vector2 clamp(Vector2 min, Vector2 max) {
    final xClamped = x.clamp(min.x, max.x);
    final yClamped = y.clamp(min.y, max.y);
    return Vector2(xClamped, yClamped);
  }
}
