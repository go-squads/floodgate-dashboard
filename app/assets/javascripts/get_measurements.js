$(document).ready(function(){
    temp = $('.selectpicker').siblings().attr("title");
    $.get(temp+"/fieldset");
    $('.selectpicker').on('change', function(e){
        temp = this.value;
        console.log(temp);
        $.get(temp+"/fieldset");
    });
});
