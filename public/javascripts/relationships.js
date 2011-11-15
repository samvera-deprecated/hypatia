$(document).ready(function() {
  
  // Make member list sortable to receive "dropped" items
  $( "#member-list" ).sortable({
    revert: false,
    revertDuration: false,
    update: function(event, ui) {
	 		// Add unsaved class so the user knows that they need to save.
	 		$("#relationship-editor .member-pane").addClass("unsaved");
      // Ensure that all items have a "remove" link
      $('.remove-relationship').remove();
      var members = $("#member-list li");
      members.append('<a href="#" class="remove-relationship">Remove</a>');
    }
  });
  
  // Allow for drag'n'drop for marked and other item list
	enableDrag($( "#item-list li, #marked-list li" ));	
	// Avoid conflicting events
	$( "ul, li" ).disableSelection();
	
	// Display member list IDs on save
	$("#relationship-save").click(function() {
	  var pids = [];
	  $("#member-list li").each(function(index) {
	    pids.push("child_ids[]=" + $(this).attr("id"));
	  });
	  $.ajax({
		  url: $(this).attr("data-update-path") + "?" + pids.join("&"),
		  success: function() {
			  // remove the unsaved class so the user knows that the relationships were properly saved.
			  $("#relationship-editor .member-pane").removeClass("unsaved");
		  },
		  error: function() {
			  alert("Error");
		  }
		});
	});
	
	// Moves item back to list of origin when removed
	// or just delete it if it started in member list
	$(".remove-relationship").live('click', function() {
		// Add unsaved class so the user knows that they need to save.
 		$("#relationship-editor .member-pane").addClass("unsaved");
	  var removed = $(this).parent();
	  removed.fadeOut('300', function(){
	    removed.children('.remove-relationship').remove();
	    if(removed.hasClass("marked")) {
	      removed.appendTo("#marked-list");
	      enableDrag(removed);
      	removed.fadeIn('300');
	    } else if(removed.hasClass("item")) {
	      removed.appendTo("#item-list");
	      enableDrag(removed);
	      removed.fadeIn('300');
      } else {
	      removed.remove();
      }
	  });
	  return false;
	});
	
	// Allow elements to be dragged to sortable member list
	function enableDrag(el) {
	  el.draggable({
  	  connectToSortable: "#member-list",
  		helper: "original",
  		revert: "invalid"
  	});
	}
});