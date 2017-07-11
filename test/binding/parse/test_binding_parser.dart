
import 'dart:html';
import "package:test/test.dart";

import '../../../lib/src/binding/binding_parser.dart';

void BindingParserTest(){

  const String HTML_ID_MAIN_NODE = 'id_main_node';

  TemplateElement e = document.getElementById(HTML_ID_MAIN_NODE);

  group("Binding Parser - Html Dom", (){
    test("Get div element", () {
      expect(e, isNotNull);
    });

    List<BaseToken> lTokens = BindingParser.parseTokensStr(e.content.text);
    test("Number of tokens", () {
      expect(lTokens.length, 6);
    });

    test("Type first token", () {
      expect(lTokens[0].runtimeType, new LiteralToken('').runtimeType);
    });

    test("Type fourth token", () {
      expect(lTokens[3].runtimeType, new BindingToken('').runtimeType);
    });

    test("Content third token", () {
      expect(lTokens[2].idStr, ' between ');
    });

    test("Type fith token", () {
      expect(lTokens[4].idStr, 's2');
    });

  });
}