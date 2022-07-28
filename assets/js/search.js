$( document ).ready(function() {
				$("#search").click(function(){
				$("#search-nav").slideToggle("500", "easeInOutCirc");
				$(".sb").focus();
				$("#search").hide("500", "easeInOutCirc");
				$("#header-carousel").css( { "margin-top" : "120px","transition" : "0.3s" } );
				$(".top-section").css( { "margin-top" : "170px","transition" : "0.3s" } );
				
				});
				$("#close-search").click(function(){
				$("#search-nav").slideToggle("500", "easeInOutCirc");
				$(".sb").focus();
				$("#search").show("500", "easeInOutCirc");
				$("#header-carousel").css( { "margin-top" : "80px","transition" : "0.3s" } );
				$(".top-section").css( { "margin-top" : "110px", "transition" : "0.3s" } );
				
				});
});
				