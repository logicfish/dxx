/**
Copyright: 2018 Mark Fisher

License:
Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
**/
module dxx.app.cache;

//private import hunt.cache;

private import dxx.app;


class BasicCache {
  // Cache cache;

  CachedValue!T get(T)(string id) {
      //return cache.get!T(id);
      return null;
  }
  void set(T)(T t,string id) {
      //cache.put!T(id,t);
  }

  this() shared {
    //cache = cast(shared(Cache))CacheFectory.create();
  }

  this() {
    //cache = CacheFectory.create();
  }

  class CachedValue(T) {
    T t;
    alias t this;
    bool isNull() {
      return t is null;
    }
    auto ref origin() {
      return t;
    }
  }
}

/*struct MemoryCache {

}

struct RedisCache {

}*/

//class Cache {
  //
//}

interface CacheProvider {
//  Cache getCache(string id="");
}
