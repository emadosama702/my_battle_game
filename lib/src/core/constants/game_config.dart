class GameConfig {
  // Frame rate
  static const int targetFPS = 60;

  // Player settings
  static const double playerMaxHealth = 100;
  static const double playerMaxMana = 100;
  static const double playerMoveSpeed = 4.0;

  // Enemy AI settings (Hard Mode)
  static const double enemyMaxHealth = 120;
  static const double enemyMaxMana = 120;
  static const double enemyMoveSpeed = 4.5;
  static const double enemyAttackRange = 2.0; // tiles/meters
  static const double enemyReactionTime = 0.3; // seconds to respond

  // Skills cooldowns (in seconds)
  static const double basicAttackCooldown = 0.5;
  static const double skill1Cooldown = 5.0;
  static const double skill2Cooldown = 7.0;
  static const double skill3Cooldown = 10.0;
  static const double ultiCooldown = 20.0;

  // Ultimate settings
  static const double ultiChargeRequired = 100; // yellow bar value
  static const double ultiDamageMultiplier = 9999; // instant kill

  // Stamina/mana costs
  static const double basicAttackManaCost = 0;
  static const double skill1ManaCost = 20;
  static const double skill2ManaCost = 30;
  static const double skill3ManaCost = 40;
  static const double ultiManaCost = 80;

  // Physics
  static const double gravity = 9.8;
  static const double jumpForce = 12.0;

  // Arena size
  static const double arenaWidth = 800; // pixels or world units
  static const double arenaHeight = 600;
}
