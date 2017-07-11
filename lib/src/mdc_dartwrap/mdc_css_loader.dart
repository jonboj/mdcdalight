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

import '../util/load_sync_starter.dart';
import '../util/log_mdcda.dart';

import 'mdc_webjs_path.dart';

class MdcComp {
  static const String TOOLBAR = 'toolbar';
  static const String TYPOGRAPHY = 'typography';
  static const String THEME = 'theme';
  static const String LIST = 'list';
  static const String ELEVATION = 'elevation';

  static const List<String> BASE_COMP = const [ELEVATION, LIST, THEME, TOOLBAR, TYPOGRAPHY];
}

class MdcCSSLoader {

  static const String MDC = 'mdc.';
  static const String CSS_EXT = '.css';

  static loadCss(final List<String> comps) async {
    List<String> cssFiles =
      comps.map((final String name) => MDC_WEBJS_PATH + MDC + name + CSS_EXT).toList();

    await new LoadSyncStarter().startLoadOfElement(loadComplete, cssFiles);
  }
}

void loadComplete(){
  LogMdcda log = new LogMdcda.fromType(MdcCSSLoader);
  log.info('loadComplete');
}