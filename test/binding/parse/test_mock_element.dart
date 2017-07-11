
import '../../../lib/src/binding/binding_types.dart';

class ElemMock {
  int v1;
  String s2 = '';
  String prefix = '';

  List<Bind> _listBW;
  Map<String, Bind> bindingsMap;

  ElemMock(){

    PropertyBind pV1 = new PropertyBind('v1', () => v1 );
    PropertyBind pS2 = new PropertyBind('s2', () => s2 );
    final Function fStr = () => composedStr(prefix);
    ComputedBind pC3 = new ComputedBind('composedStr(prefix)', fStr, [pV1.signatureDom, pS2.signatureDom]);
    _listBW = [pV1, pS2, pC3];

    bindingsMap = {pV1.signatureDom : pV1, pS2.signatureDom : pS2, pC3.signatureDom : pC3};
  }

  String composedStr(final String prefixStr){
    return prefixStr + s2 + ' composedStr with : ' + v1.toString();
  }

  Bind getBindStr(final String idStr){
    return bindingsMap[idStr];
  }

  Bind getBind(int index){
    return _listBW[index];
  }
}
