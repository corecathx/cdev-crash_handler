package ;

import haxe.ui.containers.dialogs.MessageBox.MessageBoxType;
import sys.io.Process;
import haxe.ui.containers.dialogs.Dialogs;
import haxe.ui.containers.dialogs.Dialog;
import sys.thread.Thread;
import haxe.ui.util.Timer;
import sys.FileSystem;
import sys.io.File;
import haxe.ui.containers.VBox;

@:build(haxe.ui.ComponentBuilder.build("assets/xml/update-view.xml"))
class UpdateView extends VBox {
    var allFiles:Int = 0;
    var doneFiles:Int = 0;

    var updateFrom:String = "./update/raw";
    var skipThis:Array<String> = [
        "./cdev-crash_handler.exe",
        "./lime.ndll"
    ];

    var curText:String = "";
    var curPos:Int = 0;

    var done:Bool = false;
    public function new() {
        super();
        if (!FileSystem.exists(updateFrom)){
            Dialogs.messageBox('Couldn\'t find update files.', 'CDEV Engine', 'exit');
        }
        updateBar.indeterminate = true;
        Timer.delay(executeUpdate, 3000);
    }

    public function executeUpdate(){
        updateBar.indeterminate = false;
        updateBar.min = 0;
        updateBar.max = allFiles = getFileCount(updateFrom, ".");
        updateText.text = "Hold on.";
        Thread.create(()->{
            try{
                copyFilesFromDirectory(updateFrom, ".");
            } catch(e){
                curText = "Failed: " + e.toString();
                Dialogs.messageBox("Failed updating, error:\n" + e.toString(), 'CDEV Engine', MessageBoxType.TYPE_ERROR);
            }
        });

        simulateUpdateFrames();
    }

    public function simulateUpdateFrames() {
        if (done) return;
        updateBar.pos = doneFiles;
        updateText.text = curText;
        if (doneFiles >= allFiles){
            onFinished();
        }
        Timer.delay(simulateUpdateFrames, 50);
    }

    function copyFilesFromDirectory(from:String, to:String){
        var files:Array<String> = FileSystem.readDirectory(from);
        for (content in files){
            var joinDir:String = from+"/"+content;
            var newDir:String = "."+joinDir.substring(updateFrom.length);
            if (FileSystem.isDirectory(joinDir)){
                if (!FileSystem.exists(newDir)){
                    FileSystem.createDirectory(newDir);
                }
                copyFilesFromDirectory(joinDir, to);
            } else {
                if (!skipThis.contains(newDir)){
                    File.copy(joinDir, newDir);
                } else{
                    newDir = "Skipping: " + newDir;
                }
                doneFiles++;
                curText = newDir+"\nWe're working on it! ("+Std.int((doneFiles/allFiles)*100)+"%)";
            }
        }
    }

    function onFinished() {
        done = true;
        curText = "Finished!";
        var dl = Dialogs.messageBox('Update Finished, Do you want to open CDEV Engine?', 'CDEV Engine', 'yesno');
        dl.onDialogClosed = (e:DialogEvent) -> {
            startUpdatingSkippedStuff();

            if (e.button == DialogButton.YES)
                new Process("./CDEV Engine.exe");
            Sys.exit(0);
        }
    }

    /**
     * basically what this does just to make sure the crash handler got updated, that's all
     */
    inline function startUpdatingSkippedStuff(){
        trace("prep");

        var bat:String = "@echo off\r\n"
        + "copy /Y \".\\update\\raw\\cdev-crash_handler.exe\" \".\\cdev-crash_handler_temp.exe\" && move /Y \".\\cdev-crash_handler_temp.exe\" \".\\cdev-crash_handler.exe\r\n"
        + "copy /Y \".\\update\\raw\\lime.ndll\" \".\\lime_temp.ndll\" && move /Y \".\\lime_temp.ndll\" \".\\lime.ndll\r\n"
        + "cls\r\n"
        + "echo Finished updating leftovers.\r\n"
        + "timeout /t 3>nul\r\n"
        + "exit\r\n";

        var path:String = "./l_update.bat";
        File.saveContent(path,bat);
        new Process(path,[]);
    }
    

    function getFileCount(from:String, to:String){
        var files:Array<String> = FileSystem.readDirectory(from);
        var wa:Int = 0;
        for (content in files){
            var joinDir:String = from+"/"+content;
            var newDir:String = "."+joinDir.substring(updateFrom.length);
            if (FileSystem.isDirectory(joinDir)){
                wa += getFileCount(joinDir, to);
            } else {
                wa++;
            }
        }
        return wa;
    }
    
}