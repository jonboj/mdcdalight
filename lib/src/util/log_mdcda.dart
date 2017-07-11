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

import 'package:logging/logging.dart' as logging;

import 'utils.dart';

class Level extends logging.Level {
  static const int _SUB_LEVEL_SIZE = 10;
  const Level(final String name, final int value) : super(name, value);

  static final Level ALL = new Level(logging.Level.ALL.name, logging.Level.ALL.value);
  static final Level OFF = new Level(logging.Level.OFF.name, logging.Level.OFF.value);

  static final Level FINE = new Level('FINE ', logging.Level.FINE.value);
  static final Level DEBUG = new Level('DEBUG', logging.Level.FINE.value + _SUB_LEVEL_SIZE);
  static final Level INFO = new Level('INFO ', logging.Level.INFO.value);
  static final Level WARN = new Level('WARN ', logging.Level.WARNING.value);
  static final Level ERROR = new Level('ERROR', logging.Level.SEVERE.value);
  static final Level FATAL = new Level('FATAL', logging.Level.SEVERE.value + _SUB_LEVEL_SIZE);
}

class LogMdcda {
  final logging.Logger _logger;
  static bool _init = false;

  LogMdcda(final String name)
      : _logger = new logging.Logger(name){
    //If log system is uninitialized at creation of first log instance, then
    // init with default settings.
    if (!_init){
      init();
    }
  }

  factory LogMdcda.fromType(final Type t){
    return new LogMdcda(t.toString());
  }

  static init({final bool hierarchicalLog, final Level level}){
    _init = true;

    //Default all
    rootLevel = Level.ALL;
    if (RuntimeEnv.minimized){
      //release - only warn, error and fatal.
      rootLevel = Level.WARN;
    }

    if (level != null){
      rootLevel = level;
    }

    logging.hierarchicalLoggingEnabled = true;
    if (hierarchicalLog != null){
      logging.hierarchicalLoggingEnabled = hierarchicalLog;
    }

    logging.Logger.root.onRecord.listen((logging.LogRecord rec) {
      print('${rec.level.name} ${rec.time} ${rec.loggerName}.${rec.message}');
    });
  }

  void set level(final Level l){
    _logger.level = new logging.Level(l.name, l.value);
  }

  static void set rootLevel(final Level l){
    logging.Logger.root.level = l;
  }

  /** Log message at level [Level.FINE]. */
  void fine(message, [Object error, StackTrace stackTrace]) =>
      _logger.log(Level.FINE, message, error, stackTrace);

  /** Log message at level [Level.FINE]. */
  void debug(message, [Object error, StackTrace stackTrace]) =>
      _logger.log(Level.DEBUG, message, error, stackTrace);

  /** Log message at level [Level.INFO]. */
  void info(message, [Object error, StackTrace stackTrace]) =>
      _logger.log(Level.INFO, message, error, stackTrace);

  /** Log message at level [Level.ERROR]. */
  void error(message, [Object error, StackTrace stackTrace]) =>
      _logger.log(Level.ERROR, message, error, stackTrace);

  /** Log message at level [Level.INFO]. */
  void warn(message, [Object error, StackTrace stackTrace]) =>
      _logger.log(Level.WARN, message, error, stackTrace);

}

