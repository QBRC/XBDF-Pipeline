// http://www.xarg.org/project/jquery-webcam-plugin/
$(function() {
	$('.flash').delay(3000).slideUp('slow');
	
	$('.run :input:not(:submit)').tooltip({position: "center right", offset: [20, 0], opacity: 0.7, effect: "slide"});
	
	$(".autosubmit input:submit").hide();
	
	$(".autosubmit").change(function() {
	   this.submit();
	});
	
	
	// $('.fileTree').fileTree({ root: '', script: 'files' }, function(file) {
	// 	alert(file);
	// });
	
	$(".browse").click(function(e){
		$(this).next().slideToggle();
		e.preventDefault();
	});
	
	$('.fileTree').each(function(){
		var fileTree = this;
		$(fileTree).fileTree({ root: '', script: '../files' }, function(file) {
			var input_name = $(fileTree).attr("target");
			$('input[name="' + input_name + '"]').val(file);
		});
	});
	
	// $("label").inFieldLabels();
	
	// $("#camera").webcam({
	//         width: 320,
	//         height: 240,
	//         mode: "callback",
	//         swffile: "/javascripts/jscam_canvas_only.swf",
	//         onTick: function() {},
	//         onSave: function() {},
	//         onCapture: function() {
	// 			jQuery("#flash").css("display", "block");
	// 	        jQuery("#flash").fadeOut("fast", function () {
	// 	                jQuery("#flash").css("opacity", 1);
	// 	        });
	// 			
	// 	        webcam.save();
	// 		},
	//         debug: function() {$("#status").html(type + ": " + string);},
	//         onLoad: function() {
	// 		    var cams = webcam.getCameraList();
	// 		    for(var i in cams) {
	// 		        jQuery("#cams").append("<li>" + cams[i] + "</li>");
	// 		    }
	// 		}
	// });
});