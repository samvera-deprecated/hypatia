$(document).ready(function() {
  
  // Make member list sortable to receive "dropped" items
  $( "#member-list" ).sortable({
    revert: false,
    revertDuration: false,
    update: function(event, ui) {
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
	    pids.push($(this).attr("id"));
	  });
	  alert("Here's the array of PIDs for this item's child assets: \n\n" + pids + "\n\nSave 'em somewhere!");
	});
	
	// Moves item back to list of origin when removed
	// or just delete it if it started in member list
	$(".remove-relationship").live('click', function() {
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