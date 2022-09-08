$(document).ready(function(){
	"use strict";
    
    // 1. Scroll To Top 
		$(window).on('scroll',function () {
			if ($(this).scrollTop() > 600) {
				$('.return-to-top').fadeIn();
			} else {
				$('.return-to-top').fadeOut();
			}
		});
		$('.return-to-top').on('click',function(){
				$('html, body').animate({
				scrollTop: 0
			}, 1500);
			return false;
		});
	
				$('.play').on('click',function(){
					owl.trigger('play.owl.autoplay',[1000])
				})
				$('.stop').on('click',function(){
					owl.trigger('stop.owl.autoplay')
				})
                $(".a-refuse-cookie").click(function(){
                    $(".cookie-alert").removeClass('show');;  
                });
    // 3. slide animation

        $(function(){
        	$(".slide-hero-txt h4,.slide-hero-txt h2,.slide-hero-txt p").removeClass("animated fadeInUp").css({'opacity':'0'});
            $(".slide-hero-txt button").removeClass("animated fadeInDown").css({'opacity':'0'});
        });

        $(function(){
        	$(".slide-hero-txt h4,.slide-hero-txt h2,.slide-hero-txt p").addClass("animated fadeInUp").css({'opacity':'0'});
            $(".slide-hero-txt button").addClass("animated fadeInDown").css({'opacity':'0'});
        });
		
});
const sub = document.querySelectorAll('.sub');
const dropMenus = document.querySelectorAll('.drop-menu');

sub.forEach(lisub => {
    lisub.addEventListener('mouseover', () => {
        removeActive();
        lisub.classList.add('active');
        document.querySelector(lisub.dataset.target).classList.add('active');
		$('.close-side').hide();
    })
})

const removeActive = () => {
    sub.forEach(lisub => lisub.classList.remove('active'));
    dropMenus.forEach(dropmenu => dropmenu.classList.remove('active'));
	$('.close-side').show();
}

window.onclick = (e) => {
    if (!e.target.matches('.sub')) {
        removeActive()
    }
}
/*overlay click*/
$(".overlay-panel").click(function(){
	var spWidth = $('.sidepanel').width();
	var spMarginLeft = parseInt($('.sidepanel').css('margin-left'),10);
	var w = (spMarginLeft >= 0 ) ? spWidth * -1 : 0;
	var cw = (w < 0) ? -w : spWidth-22;
	$('.sidepanel').animate({
	  marginLeft:w
	});
	$('.sidepanel span').animate({
	  marginLeft:w
	});
	$(".overlay-panel").fadeOut();  
	$("body").removeClass("fixed-position"); 
});
/*cookie*/
(function () {
    "use strict";

    var cookieAlert = document.querySelector(".cookie-alert");
    var acceptCookies = document.querySelector(".accept-cookies");
    var refuseCookies = document.querySelector(".refuse-cookie");

    cookieAlert.offsetHeight;

    if (!getCookie("acceptCookies")) {
        cookieAlert.classList.add("show");
    }

    acceptCookies.addEventListener("click", function () {
        setCookie("acceptCookies", true, 60);
        cookieAlert.classList.remove("show");
    });

    refuseCookies.addEventListener("click", () => {
        setCookie("acceptCookies", false, 60);
    })
})();

// Cookie functions
function setCookie(cname, cvalue, exdays) {
    var d = new Date();
    d.setTime(d.getTime() + (exdays * 24 * 60 * 60 * 1000));
    var expires = "expires=" + d.toUTCString();
    document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/";
}

function getCookie(cname) {
    var name = cname + "=";
    var decodedCookie = decodeURIComponent(document.cookie);
    var ca = decodedCookie.split(';');
    for (var i = 0; i < ca.length; i++) {
        var c = ca[i];
        while (c.charAt(0) === ' ') {
            c = c.substring(1);
        }
        if (c.indexOf(name) === 0) {
            return c.substring(name.length, c.length);
        }
    }
    return "";
}
/*slide in header*/
$(document).ready(function(){
$('#header-carousel').mouseover(function(){
    $('.prev-slide').show();
    $('.next-slide').show();
});
$('#header-carousel').mouseout(function(){
    $('.prev-slide').hide();
    $('.next-slide').hide();
  });
});