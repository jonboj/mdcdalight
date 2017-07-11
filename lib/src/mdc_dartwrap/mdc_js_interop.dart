// Copyright 2017 Jonas Bojesen. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

@JS()
library mdcjs;

import 'dart:html';
import "package:js/js.dart";

@JS()
class MDCTemporaryDrawer {
  external factory MDCTemporaryDrawer(final Element e);
  external void set open(final bool state);
}

@JS()
class MDCSimpleMenu {
  external factory MDCSimpleMenu(final Element e);
  external void set open(final bool state);
}

@JS()
class MDCTextfield {
  external factory MDCTextfield(final Element e);
}

//Used to provide MDCSnackbar with js literal argument.
@anonymous
@JS()
class SnackbarMessage {
  external String get message;
  external factory SnackbarMessage({String message});
}

@JS()
class MDCSnackbar {
  external factory MDCSnackbar(final Element e);
  external void show(final SnackbarMessage message);
}