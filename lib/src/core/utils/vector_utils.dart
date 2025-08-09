import 'package:flame/components.dart';

class VectorUtils {
  /// حساب المسافة بين نقطتين
  static double distance(Vector2 a, Vector2 b) {
    return a.distanceTo(b);
  }

  /// تحويل اتجاه (من A إلى B) إلى Vector2 مع تطبيع الطول
  static Vector2 direction(Vector2 from, Vector2 to) {
    return (to - from).normalized();
  }

  /// تحريك نقطة بسرعة معينة في اتجاه معين
  static Vector2 moveTowards(Vector2 current, Vector2 target, double speed, double dt) {
    final dir = direction(current, target);
    return current + dir * speed * dt;
  }

  /// التحقق إذا كانت المسافة بين نقطتين أقل أو تساوي قيمة معينة
  static bool isWithinDistance(Vector2 a, Vector2 b, double distance) {
    return a.distanceTo(b) <= distance;
  }
}
