(function() {
    this.listener = window.addEventListener('message', function(event)
    {
        const item = event.data
        if (this[item.type]) {
            this[item.type](item)
        }
        else {
            this.noMethod(item.type);
        }
    });

    this.CASINO_MESSAGE = (data) => {
        $("#message").html(data.message);
        $("#message").show();
        setTimeout(function(){
            $("#message").hide();
            $("#message").html("");
        },5000)
    }
    
    this.noMethod = (type) => {
        console.log('no valid method')
    }
})();

