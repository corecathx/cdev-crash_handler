package ;

import openfl.display.Application;
import sys.io.Process;
import sys.FileSystem;
import openfl.net.URLRequest;
import openfl.Lib;
import sys.io.File;
import haxe.ui.containers.VBox;
import haxe.ui.events.MouseEvent;

@:build(haxe.ui.ComponentBuilder.build("assets/xml/crash-view.xml"))
class CrashView extends VBox {
    var bunchOfTexts:Array<String> = [
        "Wait, how did this happen?",
        "Oh, the engine crashed again.",
        "I forgot to add a semicolon.",
        "Ah, a new error found.",
        "Argh, another error.",
        "Did i miss something?",
        "Congrats on finding the bug.",
        "Uhhhhh yea it crashed.",
        "Haha, CDEV Engine just crashed.",
        "Another error?",
    ];
    public function new(crashPath:String) {
        super();
        randomText.text = bunchOfTexts[Std.int(Math.random() * (bunchOfTexts.length-1))] +
        "\nCDEV Engine unexpectedly crashed during runtime.";
        call_stacks.text = File.getContent(crashPath);

        github_button.onClick = (me:MouseEvent) -> {
            trace("boom");
            Lib.getURL(new URLRequest("https://github.com/Core5570RYT/FNF-CDEV-Engine/"), "_blank");
            Sys.exit(0);
        }

        restart_button.onClick = (me:MouseEvent) -> {
            if (FileSystem.exists("./CDEV Engine.exe")){
                trace("the game should've restarted now...");
                new Process("./CDEV Engine.exe", []);
                Sys.exit(0);
                return;
            }

            lime.app.Application.current.window.alert("Restarting failed, CDEV Engine.exe is missing.", "Error");
            Sys.exit(0);
            return;
        }
    }
}