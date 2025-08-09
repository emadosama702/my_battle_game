import 'package:flame/components.dart';
import 'package:flame/input.dart';

class PlayerJoystick extends JoystickComponent {
  PlayerJoystick()
      : super(
          knob: CircleComponent(radius: 20, paint: Paint()..color = const Color(0xFFFFFFFF)),
          background: CircleComponent(radius: 50, paint: Paint()..color = const Color(0x55FFFFFF)),
          margin: const EdgeInsets.all(40),
        );
}
