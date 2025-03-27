import 'package:flame_character/flame_character.dart';
import 'package:flutter/material.dart';

class CreditsSection {
  String name;
  String content;
  Duration displayDuration;

  CreditsSection(
    this.name,
    this.content, {
    this.displayDuration = const Duration(seconds: 3),
  });

  factory CreditsSection.fromMap(Map<String, dynamic> map) {
    return CreditsSection(
      map["name"]!,
      map["content"]!,
      displayDuration: Duration(microseconds: map["displayDuration"]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "content": content,
      "displayDuration": displayDuration.inMicroseconds,
    };
  }
}

class CreditsConfig {
  bool enabled = true;
  String stageBackground = "";
  String stageBackgroundMusic = "";
  List<CreditsSection> sections = [CreditsSection("Made with", "StoryTailor.")];
  Stretch backgroundStretch;
  Curve fadeInCurve = Curves.linear;
  Curve fadeOutCurve = Curves.linear;
  Duration animationDuration;
  Color textColor;

  CreditsConfig({
    this.enabled = true,
    this.stageBackground = "",
    this.stageBackgroundMusic = "",
    this.backgroundStretch = Stretch.scaleToCover,
    this.textColor = Colors.black,
    this.animationDuration = const Duration(seconds: 1),
  });

  factory CreditsConfig.fromMap(Map<String, dynamic> map) {
    CreditsConfig config = CreditsConfig(
      enabled: map["enabled"] ?? true,
      stageBackground: map["stageBackground"] ?? "",
      stageBackgroundMusic: map["stageBackgroundMusic"] ?? "",
      backgroundStretch: Stretch.fromDisplayName(
        map["backgroundStretch"] ?? "Scale to cover",
      ),
      textColor: Color(map["textColor"] ?? 0xFF000000),
      animationDuration: Duration(
        microseconds: map["animationDuration"] ?? 1000000,
      ),
    );

    config.sections =
        (map["sections"]! as List<dynamic>)
            .map(
              (e) => CreditsSection.fromMap(
                (e as Map<String, dynamic>).map(
                  (key, value) => MapEntry(key, value),
                ),
              ),
            )
            .toList();

    return config;
  }

  Map<String, dynamic> toMap() {
    return {
      "enabled": enabled,
      "stageBackground": stageBackground,
      "stageBackgroundMusic": stageBackgroundMusic,
      "backgroundStretch": backgroundStretch.displayName,
      "textColor": textColor.toARGB32(),
      "animationDuration": animationDuration.inMicroseconds,
      "sections": sections.map((e) => e.toMap()).toList(growable: false),
    };
  }
}
