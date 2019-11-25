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
module dxx.services.net.http;

import std.exception : enforce;


/*
import vibe.core.log;
import vibe.http.fileserver;
import vibe.http.router;
import vibe.http.server;
import vibe.utils.validation;
import vibe.web.web;
*/
import dxx.app;

import dxx.service;

class HTTPService : ServiceBase {
    this() {
  /*  	// Create the router that will dispatch each request to the proper handler method
    	auto router = new URLRouter;
    	// Register our sample service class as a web interface. Each public method
    	// will be mapped to a route in the URLRouter
    	//router.registerWebInterface(this);
    	// All requests that haven't been handled by the web interface registered above
    	// will be handled by looking for a matching file in the public/ folder.
    	router.get("*", serveStaticFiles("public/"));

    	// Start up the HTTP server
    	auto settings = new HTTPServerSettings;
    	settings.port = 8080;
    	settings.bindAddresses = ["::1", "127.0.0.1"];
    	settings.sessionStore = new MemorySessionStore;
    	listenHTTP(settings, router);

    	logInfo("Please open http://127.0.0.1:8080/ in your browser.");
      */
    }
}
