/**
Copyright 2018 Mark Fisher

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
module dxx.util.stream;

private import dxx.util.notify;



interface Closeable {
  void onClose(void delegate());
}

interface Channel : Closeable {
  void onOpen(void delegate());
}

interface InputChannel : Channel {
    void onRead(void delegate(byte[]));
}

interface OutputChannel : Channel {
    void onWrite(byte[] delegate());
}

interface IOChannel : InputChannel,OutputChannel {
}

interface ConnectionChannel : Channel {
    void onConnect(void delegate(IOChannel));
}

class ChannelImpl : SyncNotificationSource,Channel {
  void delegate()* _onClose;
  void onClose(void delegate() d) {
    _onClose = &d;
  }
  void delegate()* _onOpen;
  void onOpen(void delegate() d) {
    _onOpen = &d;
  }
  void close() {
    if(_onClose !is null) {
      (*_onClose)();
    }
  }
  void open() {
    if(_onOpen !is null) {
      (*_onOpen)();
    }
  }
}

class InputChannelImpl : ChannelImpl,InputChannel {
  void delegate(byte[])* _onRead;
  void onRead(void delegate(byte[]) d) {
    _onRead = &d;
  }
  void read(byte[] b) {
    if(_onRead !is null) {
      (*_onRead)(b);
    }
  }
}
class OutputChannelImpl : ChannelImpl,OutputChannel {
  byte[] delegate()* _onWrite;
  void onWrite(byte[] delegate() d) {
    _onWrite = &d;
  }
  byte[] write() {
    if(_onWrite !is null) {
      return (*_onWrite)();
    }
    return null;
  }
}
class IOChannelImpl : ChannelImpl,IOChannel {
  void delegate(byte[])* _onRead;
  void onRead(void delegate(byte[]) d) {
    _onRead = &d;
  }
  void read(byte[] data) {
    if(_onRead !is null) {
      (*_onRead)(data);
    }
  }
  byte[] delegate()* _onWrite;
  void onWrite(byte[] delegate() d) {
    _onWrite = &d;
  }
  byte[] write() {
    if(_onWrite !is null) {
      return (*_onWrite)();
    }
    return null;
  }
}
class ConnectionChannelImpl : ChannelImpl,ConnectionChannel {
  void delegate(IOChannel)* _onConnect;
  void onConnect(void delegate(IOChannel) d) {
    _onConnect = &d;
  }
  void connect(IOChannel c) {
    if(_onConnect !is null) {
      (*_onConnect)(c);
    }
  }
}
