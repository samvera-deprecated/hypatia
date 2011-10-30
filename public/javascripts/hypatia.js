$(document).ready(function(){	
	$(".show_image").each(function(){
	  var image_el = $(this);
	  var image = image_el.html();
	  image_el.click(function(){
		  $("body").append("<div class='image-lightbox'>" + image + "</div>");
		  $(".image-lightbox").each(function(){
				var lightbox = $(this);
				var lb_img = $("img",lightbox);
				// How can we remove the attributes all together?
				lb_img.attr("height",lb_img.height() * 4);
				lightbox.click(function(){
					lightbox.remove();
				});
			});
	  });
	});
	
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

  $("#facets h3").each(function(){
	  var h3 = $(this);
	  var toggle_span = $(".facet-toggle", h3);
	  var toggle_open = "[+]";
	  var toggle_closed = "[-]";
	  toggle_span.toggle();
	  h3.click(function(){
		  h3.next("ul").each(function(){
				$(this).slideToggle();
		  });
		  if(toggle_span.text() == toggle_open) {
			  toggle_span.text(toggle_closed);
		  }else{
			  toggle_span.text(toggle_open);
		  }
	  });
	  if(h3.attr("id") != "facet_repository"){
		  h3.next("ul").each(function(){
			  if($('span.selected', $(this)).length == 0){
				  $(this).toggle();
			  }
		  });
	  }else{
		  toggle_span.text(toggle_closed);
	  }
  });

  $( "form.folder_toggle" ).bl_checkbox_submit({
      checked_label: "Selected",
      unchecked_label: "Select",
      css_class: "toggle_folder",
      success: function(new_state) {
        
        if (new_state) {
           $("#folder_number").text(parseInt($("#folder_number").text()) + 1);
        }
        else {
           $("#folder_number").text(parseInt($("#folder_number").text()) - 1);
        }
      }
  });

  $("a.destructive").each(function(){
	  var link = $(this);
	  link.click(function(){
		  var prev_input = link.prev("input")
		  prev_input.val("");
		  link.toggle();
		  prev_input.toggle();
		  return false;
	  });
  });
});