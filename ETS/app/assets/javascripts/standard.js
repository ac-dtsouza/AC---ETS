$(document).ready(function(){

	// FUNCTIONS
	
	function load(url){
		//alert(url);return;
		if( !url.match(/locale/) ){
			if( !url.match(/\?/) ){
				url += "?";
			}else{
				url += "&";
			}
			url += "locale="+LOCALE;
		}
		//alert(url+" #content");
		$("#content").load(url+" #content", function(response, status, xhr) {
			//alert( response );
			if (status.match(/error/)){
				var error = response.split("<body>");
					error = error[1].split("</body>");
				$("#content").html(error[0]);
			}
		});
	}
	
	function nospaces(str){
		return str.replace(/ /g, "%20");
	}
	
	
	
	// EVENTS
	
	/** Header Menu */
	$("#header ul li").click(function(e){
		e.preventDefault();
		var id = $(this).attr("id");
		switch(id){
			case "logoff": window.location = "/root/logoff?locale="+LOCALE; break;
			default: load("/root/"+id);
		}
	});
	
	/** Frequency Month List Menu */
	$(document).delegate("#month_list li, #month li.active", "click", function(e){
		e.preventDefault();
		load($(this).children("a").attr("href"));
	});
	
	/** Frequency => Month => Day */
	/** Edit */
	$(document).delegate("a.button, a.link", "click", function(e){
		e.preventDefault();
		var href = $(this).attr("href");
		if( !href.match(/#/) ){
			load(href);
		}else if( href.match(/save/) ){ // On-Call
			$(this).siblings("a").removeAttr("style");
			$(this).parent().after("<span class='block'><input id='time' name='time' type='text' class='clear_left' /><a class='button' style='visibility: hidden;' href='#remove'>"+$(this).siblings("a").html()+"</a><a class='button' href='#save'>"+$(this).html()+"</a></span>");
		}else if( href.match(/remove/) ){ // On-Call
			$(this).parent().remove();
		}
	});
	
	/** Frequency => Month => Day => "Rectify" => "Save" */
	$(document).delegate("#nosubmit", "submit", function(e){
		e.preventDefault();
		var key = $(this).children("input[name=key]");
		load($(this).attr("action")+"?rectify="+$(this).children("input[name=rectify]").val()+"&date="+$(this).children("input[name=date]").val()+"&time="+$(this).children("p").children("input[name=time]").val()+(key.length == 1 ? "&key="+key.val() : ""));
	});
	
	/** Edit */
	$(document).delegate("#users", "change", function(e){
		e.preventDefault();
		var url = "/root/edit?id="+$(this).val();
		load(url);
	});
	
	/** Edit Holidays */
	$(document).delegate("form[name^=holiday]", "submit", function(e){
		e.preventDefault();
		url = $(this).attr("action")+"?day="+$(this).find("input[name=day]").val();
		if( $(this).attr("name").match(/save/) ){
			url += "&desc="+nospaces($(this).find("input[name=desc]").val())+"&id="+$(this).find("input[name=id]").val()+"&ajax=true";
		}
		load( url );
	});
	
	//alert("Not broken yet");
	
});