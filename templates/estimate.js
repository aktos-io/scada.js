oneDecimal = function(inp) {
    var appSec = parseInt(inp / 1000);
    var appMSec = parseInt((inp - appSec * 1000) / 100);
    return appSec + '.' + appMSec
}

var appStart = Date.now()
var estimatedVendorToAppSizeRatio = 2;
headDuration = appStart - window.headStart;
appDuration = estimatedVendorToAppSizeRatio * headDuration;
interval = 100;
timer = document.getElementById("timer");
update = function(){
    var left = appStart + appDuration - Date.now()
    timer.innerHTML = oneDecimal(left) + " s";
    if (left > 0){
        setTimeout(update, interval);
    } else {
        timer.innerHTML = "Opening..."
    }
}
update()
