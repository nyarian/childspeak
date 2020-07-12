enum ChildSpeakFont { balsamiqSans }

extension ResourceBridge on ChildSpeakFont {
  String get asFontFamilyAttribute => _fontResourceMapping[this];
}

const Map<ChildSpeakFont, String> _fontResourceMapping =
    <ChildSpeakFont, String>{
  ChildSpeakFont.balsamiqSans: 'BalsamiqSans',
};
