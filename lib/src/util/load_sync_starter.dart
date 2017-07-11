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

import 'dart:html';
import 'dart:async';

import '../custom_element/html_import_manager.dart';
import '../util/log_mdcda.dart';

typedef void StartFunc_t();

class LoadSyncStarter {

  static final LogMdcda _log = new LogMdcda.fromType(LoadSyncStarter);

  final Completer _completer = new Completer();
  StartFunc_t _startMethod;

  List<LinkElement> lLinks = new List<LinkElement>();

  Future startLoadOfElement(StartFunc_t startMethod, final List<String> linkElemNames) {
    _startMethod = startMethod;

    linkElemNames.forEach((final String name){

      LinkElement linkElement = HtmlImportManager.insertLink(name);
      lLinks.add(linkElement);

      if (linkElement == null){
        _log.warn('startLoadOfElement linkElement null, file : ' + name);
      }

      linkElement.onLoad.listen((final Event e){
        _log.info('startLoadOfElement load event : ' + linkElement.href);
        lLinks.remove(linkElement);
        if (lLinks.isEmpty){
          recievedAllEvents();
        }
      });

    });
    return _completer.future;//Send future object back to client.
  }

  void recievedAllEvents() {
    _log.info('recievedAllEvents');
    _completer.complete();
    _startMethod();
  }

}
