$( document ).ready(function() {
				$("#search").click(function(){
				$("#search-nav").slideToggle("500", "easeInOutCirc");
				$(".sb").focus();
				$("#search").hide("500", "easeInOutCirc");
				$("#header-carousel").css( { "margin-top" : "130px","transition" : "0.3s" } );
				$(".top-section").css( { "margin-top" : "140px","transition" : "0.3s" } );
				$(".sidepanel").css( { "margin-top" : "50px","transition" : "0.3s" } );
				});
				$("#close-search").click(function(){
				$("#search-nav").slideToggle("500", "easeInOutCirc");
				$(".sb").focus();
				$("#search").show("500", "easeInOutCirc");
				$("#header-carousel").css( { "margin-top" : "80px","transition" : "0.3s" } );
				$(".top-section").css( { "margin-top" : "90px", "transition" : "0.3s" } );
				$(".sidepanel").css( { "margin-top" : "0px","transition" : "0.3s" } );
			
				});
});
				