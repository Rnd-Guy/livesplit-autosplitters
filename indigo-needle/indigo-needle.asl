/**
  * I wanna be the indigo needle autosplitter
  *
  * Uses room changes to detect progress
  * However credits room change doesn't happen until after the fade out so real time is 5 seconds faster
  *
  * Inspired a little by Gaphodil's "I Wanna Escape Heavenly Host" autosplitter
  */

state("indigo needle") {
    int level : "indigo needle.exe", 0x516370;
    
    // Levels:
    //     1 : load game new game screen
    //     2 : first screen
    //     8 : boss 1
    //     9 : after boss 1
    //     14 : last boss
    //     16 : credits - note this has a fade out animation before room actually transitions, need to take 5 seconds off to get the real time
    
}

startup {
    refreshRate = 50;

    settings.Add("reachBoss1", true, "Reach Boss 1");
    settings.SetToolTip("reachBoss1", "Entering the first boss room (genie)");

    settings.Add("afterBoss1", true, "Beat Boss 1");
    settings.SetToolTip("afterBoss1", "Leaving the first boss room and entering the next needle screen");

    settings.Add("reachFinalBoss", true, "Reach Final Boss");
    settings.SetToolTip("reachFinalBoss", "Leaving the last needle screen and entering the room with the final saves before the final boss");

    settings.Add("autoReset", false, "Auto Reset"); 
    settings.SetToolTip("autoReset", "Resets automatically when in the beginning load screen (ie F2 screen)");

}

init {
    vars.stage = "";
    vars.stages = new Dictionary<string, Tuple<int, string> >() {
        // key is just compared to var.stage to prevent splitting whilst already in the stage
        // the int is the level id
        // the second string is the settings key, which is true

        {"1b", Tuple.Create(8, "reachBoss1")}, // first boss
        {"2", Tuple.Create(9, "afterBoss1")},  // second stage
        {"2b", Tuple.Create(14, "reachFinalBoss")}, // second boss
        {"end", Tuple.Create(16, "")} // credits
    };
}

reset {
    if (settings["autoReset"]) {
        // not sure if it's bad to return true every frame
        return old.level != 1 && current.level == 1;
    }
}

onReset {
    vars.stage = "";
}

start {
    // note this will also trigger if you load a game in the first needle screen
    if (old.level == 1 && current.level == 2) {
        vars.stage = "1";
        return true;
    }
}

split {

    foreach(var item in vars.stages) {
        if (vars.stage != item.Key && current.level == item.Value.Item1 && // check we just made the transition
            (item.Value.Item2.Length == 0 || settings[item.Value.Item2])  // check if split is settings reliant
        ) {
            // store progress so we don't split multiple times in the same stage
            vars.stage = item.Key;
            return true;
        }
    }
}