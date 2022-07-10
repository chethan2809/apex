({
    newGameClick : function(component, event, helper) {
        //access the combox
        let gameModeCombox = component.find("startGame");
        //access the value of combox
        let selectedValue = gameModeCombox.get("v.value")

        console.log("New game strats");
    },
    reshuffleClick: function(component, event, helper) {

        console.log("Reshuffling the game");
    },
})