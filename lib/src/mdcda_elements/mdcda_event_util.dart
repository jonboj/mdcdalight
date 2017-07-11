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

import '../util/log_mdcda.dart';

abstract class MdcdaEvent {
  static const String MDCDA_PRFIX = 'mdcda';
  final String type;
  const MdcdaEvent(final String locType)
      : type = MDCDA_PRFIX + '-' + locType;
}

typedef void mdcdaEventHandler_t(final MdcdaEvent e);

//Small event util that piggy back the MdcdaEvent in a CustomEvent.
class MdcdaEventUtil {

  static final LogMdcda _log = new LogMdcda.fromType(MdcdaEventUtil);

  static dispatch(final HtmlElement originElem, final MdcdaEvent event){
    //Put the event as detail.
    originElem.dispatchEvent(new CustomEvent(event.type, detail: event));
  }

  static registerHandler(final HtmlElement originElem, final String type, final mdcdaEventHandler_t handler){
    originElem.addEventListener(type, wrapMdcdaHandler(handler));
  }

  static EventListener wrapMdcdaHandler(final mdcdaEventHandler_t handler){
    return (Event event){
      //Should be a CustomEvent.
      if (event is! CustomEvent){
        _log.warn('wrapMdcdaHandler - type mitchmath got : ' + event.runtimeType.toString() + ',  ' + event.type);
        return;
      }

      //Stored in detail.
      MdcdaEvent mdcdaEvent = (event as CustomEvent).detail;

      if (mdcdaEvent == null){
        _log.warn('wrapMdcdaHandler - detail is null, event type : ' + event.type);
        return;
      }

      //Pick the MdcdaEvent and invoke handler.
      handler(mdcdaEvent);
    };
  }

}