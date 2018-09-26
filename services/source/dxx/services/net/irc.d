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
module dxx.services.net.irc;

import ircbod.client, ircbod.message;

import dxx.util;

class IRCClientService : SyncNotificationSource {

    IRCClient bot;
    this() {
        bot = new IRCClient("irc.freenode.net", 6667, "ircbod", null, ["#ircbod"]);
    //}
    //void bot(string[] args)
    //{
        //bot.on(IRCMessage.Type.MESSAGE, r"^hello (\S+)$", (msg, args) {
        //    msg.reply("Hello to you, too " ~ msg.nickname ~ "! You greeted: " ~ args[0]);
        //});
        //
        bot.on(IRCMessage.Type.PRIV_MESSAGE, r"^!quit$", (msg) {
            msg.reply("Yes, master.");
            bot.broadcast("My master told me to quit. Bye!");
            bot.quit();
        });

        bot.on(IRCMessage.Type.JOIN, (msg) {
//            writeln("User joined: ", msg.nickname);
            if(msg.nickname != bot.name)
                msg.reply("Welcome to the channel, " ~ msg.nickname);
        });

        bot.on(IRCMessage.Type.CHAN_MESSAGE, (msg) {
//            writeln("got chan message: ", msg.text);
        });

        bot.on(IRCMessage.Type.PRIV_MESSAGE, (msg) {
//            writeln("got private message: ", msg.text);
        });
    
        bot.run();
}
}
