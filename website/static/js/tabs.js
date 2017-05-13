(function($) {

	var tabs =  $(".tabs li a");
  
	tabs.click(function() {
		var content = this.hash.replace('/','');
		tabs.removeClass("activetab");
		$(this).addClass("activetab");
    $("#content").find('div.pane').hide();
    $(content).show();
	});

})(jQuery);

$(".activetab").each(function() {
	var tabs =  $(".tabs li a");
		var content = this.hash.replace('/','');
		tabs.removeClass("activetab");
		$(this).addClass("activetab");
    $("#content").find('div.pane').hide();
    $(content).show();
	});
