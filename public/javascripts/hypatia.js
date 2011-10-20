$(document).ready(function(){
	$(".start-shut").each(function(){
		$(this).toggle();
	});
	$(".show-hide").each(function(){
		var toggle_link = $(this);
		toggle_link.toggle();
		toggle_link.click(function(){
			toggle_link.next(".toggle-section").slideToggle();
			toggle_text = (toggle_link.text() == "Hide Section") ? "Show Section" : "Hide Section";
			toggle_link.text(toggle_text);
		});
	});
	
	//add ajaxy dialogs to certain links, using the ajaxyDialog widget.
   $( "a.more_facets_link" ).ajaxyDialog({
       width: $(window).width() / 2,  
       chainAjaxySelector: "a.next_page, a.prev_page, a.sort_change"        
   });  
});