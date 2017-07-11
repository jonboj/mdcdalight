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

typedef T GetRefFunction<T>();
typedef void SetRefFunction<T>(final T t);

typedef Bind getBindFromStr_t(final String idStr);

//Union of two maps. For performance largeste map in m1.
Map<String, List<T>> mapUnionList<T>(Map<String, List<T>> m1, final Map<String, List<T>> m2){

  //Empty lists to new keys from m2.
  List<String> lNewKeys = m2.keys.toSet().difference(m1.keys.toSet()).toList();
  lNewKeys.forEach((final String s2) => m1[s2] = new List<T>());

  //Add all lists from m2
  m2.forEach((final String s2, final List<T> listT) => m1[s2].addAll(listT));
  return m1;
}

//Union an element to a map.
Map<String, List<T>> mapUnionElement<T>(Map<String, List<T>> m1, final Map<String, T> e2){

  //Empty lists to new keys from e2.
  List<String> lNewKeys = e2.keys.toSet().difference(m1.keys.toSet()).toList();
  lNewKeys.forEach((final String s2) => m1[s2] = new List<T>());

  //Add all lists from e2
  e2.forEach((final String s2, final T t) => m1[s2].add(t));
  return m1;
}

abstract class Bind<T> {
  final String signatureDom;

  const Bind(final String this.signatureDom);

  T get value;
}

//Only get value from property
class PropertyBind<T> extends Bind {
  final GetRefFunction _getF;//Only syntax to store a reference the property.

  PropertyBind(final String signatureDom, final GetRefFunction this._getF)
      : super(signatureDom);

  T get value => _getF();
}

//Both get and set
class PropertyBindSet<T> extends PropertyBind {
  final SetRefFunction _setF;//Only syntax to store a reference the property.

  PropertyBindSet(final String signatureDom, final GetRefFunction getF, final SetRefFunction this._setF)
      : super(signatureDom, getF);

  set value(final T t){ _setF(t); }
}

class ComputedBind<T> extends Bind {
  final GetRefFunction _method;//The method to compute the value.
  final List<String> deps;//Signatures of properties the binding depends.

  ComputedBind(final String signatureDom, final GetRefFunction this._method, final List<String> this.deps)
      : super(signatureDom);

  T get value {
    return _method();
  }
}
