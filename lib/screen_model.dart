class ScreenModel {
  double width, height;
  static final ScreenModel _screenmodel = ScreenModel._internal();

  factory ScreenModel() {
    return _screenmodel;
  }

  ScreenModel._internal();
}
