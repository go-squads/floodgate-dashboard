$(document).ready(function(){
    $('.selectpicker').on('change', function(e){
        temp = this.value;
        $.get(temp+"/fieldset");
    });
});