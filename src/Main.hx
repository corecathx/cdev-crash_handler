package;

import haxe.ui.util.Color;
import haxe.ui.Toolkit;
import haxe.ui.themes.ThemeManager;
import haxe.ui.components.Label;
import lime.app.Application;
import haxe.ui.components.Image;
import haxe.ui.HaxeUIApp;
@:buildXml('
<target id="haxe">
  <lib name="dwmapi.lib" if="windows" />
  <lib name="shell32.lib" if="windows" />
  <lib name="gdi32.lib" if="windows" />
  <lib name="ole32.lib" if="windows" />
  <lib name="uxtheme.lib" if="windows" />
</target>
')
@:cppFileCode('
#include <iostream>
#include <Windows.h>
#include <psapi.h>
#include <dwmapi.h>
#include <Shlobj.h>
#include <shellapi.h>
#include <cstdio>
')
class Main {
    public static function main() {
        var app = new HaxeUIApp();
        Toolkit.theme = "dark";
        app.title = "Friday Night Funkin': CDEV Engine";
        setWindowDarkMode(Application.current.window.title, true);
        Application.current.window.resizable = false;

        inline function hi(){
            Application.current.window.width = 440;
            Application.current.window.height = 48;
            var a = new Label();
            a.percentWidth = 100;
            var random = [
                "hi :]",
                "wow you found me",
                "...lol",
                "eh",
                "ooo... you're going to click that close button ooo...",
                "oh.",
                "ehhhh, what?",
                "what do you expect to see here",
                "hey there",
                "lol you opened the wrong file i guess",
                "here's your thing: 127.0.0.1",
                "hi",
                "heheh"
            ];            
            a.text = random[Std.int(Math.random()*random.length)];
            a.color = Color.fromString("white");
            app.addComponent(a);
        }

        app.ready(function() {
            if (Sys.args().length > 0){
                switch (Sys.args()[0].toLowerCase()){
                    case "crash":
                        app.addComponent(new CrashView(Sys.args()[1]));
                    case "update":
                        app.addComponent(new UpdateView());
                    default: hi();
                }
            } else {
                hi();
            }
            
            app.start();
        });
    }

    @:functionCode('
        int darkMode = enable ? 1 : 0;
        
        HWND window = FindWindowA(NULL, title.c_str());
        if (window == NULL) window = FindWindowExA(GetActiveWindow(), NULL, NULL, title.c_str());
        
        if (window != NULL && S_OK != DwmSetWindowAttribute(window, 19, &darkMode, sizeof(darkMode))) {
            DwmSetWindowAttribute(window, 20, &darkMode, sizeof(darkMode));
        }
    ')
    public static function setWindowDarkMode(title:String, enable:Bool) {}
}


