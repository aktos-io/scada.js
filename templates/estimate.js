
oneDecimal = function(x){
    return parseFloat(Math.round(x * 10) / 10).toFixed(1)
}
var appStart = Date.now()
var estimatedVendorToAppSizeRatio = 0.5;
headDuration = appStart - window.headStart;
appDuration = estimatedVendorToAppSizeRatio * headDuration;
interval = 100;
update = function(){
    try {
        timer = document.getElementById("timer");
        var left = appStart + appDuration - Date.now();
        timer.innerHTML = oneDecimal(left/1000) + " s";
        if (left > 0){
            setTimeout(update, interval);
        } else {
            timer.innerHTML = "Opening..."
        }
    }
    catch(e) {
        setTimeout(update, interval)
    }
}
update()
