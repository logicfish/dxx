module dxx.util.stream;

interface Stream {
}

interface InputStream : Stream {
    void onRead(void delegate(byte[]));
}

interface OutputStream : Stream {
    int write(byte[]);
}

interface IOStream : InputStream,OutputStream {
}

interface ConnectionListener {
    void onConnect(void delegate(IOStream));
}
