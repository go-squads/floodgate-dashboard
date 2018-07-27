$(document).ready(function(){
    $.get($('.selectpicker').value+"/fieldset");
    $('.selectpicker').on('change', function(e){
        temp = this.value;
        console.log(temp);
        $.get(temp+"/fieldset");
    });
});