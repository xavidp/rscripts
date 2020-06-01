ENTERO=/^[0-9]*$/;
ENTERO_POSITIVO=/^([1-9]{1})+[0-9]*$/;
LETRAS=/[a-zA-Z]+$/;
NUMBER_2DEC_POSITIVO=/^([1-9]{1})+[0-9]{0,}(\.{0,1}[0-9]{1,2})$/;
NOT_EMPTY=/\w{1,}/;
MAIL=/^[_a-zA-Z0-9-]+(\.[_a-zA-Z0-9-]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*(\.[a-zA-Z]{2,})$/;
CP=/^\\d{5}$/;
TFNO=/^((\(?\+{1}[0-9]{2,3})\)?)?(\u0020)?\d([\u0020\d]+)+$/;//^((\(?\+{1}[0-9]{2,3})\)?)?\b*\d+$/;//^((\(?\+{1}[0-9]{2,3})\)?)?\d+$/;

NUMBER_COORDS=/^\-{0,1}\d+([.,]{1}\d{1,8})?$/;
NUMBER_POSITIVO_8DEC=/^\d+([.,]{1}\d{1,8})?$/;
NUMBER_POSITIVO_2DESC=/^\d+([.,]{1}\d{1,2})?$/;

$.fn.validar=function(expresion){
    return expresion.test($(this).val().trim());
}

	$.ajaxSetup({type: 'POST',contentType:"application/x-www-form-urlencoded;charset=UTF-8"//,
	    //error: function(xhr, ajaxOptions, thrownError){        	
        	//$.infoMsj(ajaxErrorGral[$('#lang').val()]);
        //}		
	});
	
	$.fn.dialogClose= function(time) {
		var idObj="#"+$(this).attr('id');
		if(time){
			setTimeout(function () {$(idObj).dialog("close");}, time);
		}
		else{
			setTimeout(function () {$(idObj).dialog("close");}, 1000);	
		}
	}
	
	$.ajaxError=function(msj){$.errorMsj(msj);}
	
	$.infoMsj=function(msj){
		$('#txtModalMsj').html(msj);
		$('#capaModalMsj').dialog('open');
		$('#bCloseMsj').bind('click',function(event){	
			$('#capaModalMsj').dialog('close');			
		});
	}
	$.okMsj=function(msj){
		$('#divIconError').hide();
		$('#divAlternateIconError').show();
		$('#txtModalMsj').html(msj);
		$('#capaModalMsj').dialog('open');
		$('#bCloseMsj').bind('click',function(event){
			$('#divIconError').show();
			$('#divAlternateIconError').hide();
			$('#capaModalMsj').dialog('close');			
		});
	}
	
	
	$.warningMsj=function(msj){
		//$('#iconModalMsj').removeClass('infoIcon errorIcon').addClass('warningIcon');
		$('#txtModalMsj').html(msj);
		$('#capaModalMsj').dialog('open');
		$('#bCloseMsj').bind('click',function(event){		
			$('#capaModalMsj').dialog('close');
		});
	}
	$.errorMsj=function(msj){
		//$('#iconModalMsj').removeClass('infoIcon warningIcon').addClass('errorIcon');
		$('#txtModalMsj').html(msj);
		$('#capaModalMsj').dialog('open');
		$('#bCloseMsj').bind('click',function(event){		
			$('#capaModalMsj').dialog('close');
		});
	}
	
	$.activarOpcionMenu=function(idOpcion){
		$('[id^=menuCdd]').each(function () {
			$(this).removeClass('navActive');
		});
		$('#'+idOpcion).addClass('navActive');
	}
	$.activarOpcionBuscar=function(idOpcion){
		$('[id^=menuBuscar]').each(function () {
			$(this).removeClass('navBuscadorActive');
		});
		$('#'+idOpcion).addClass('navBuscadorActive');
	}
	
	$.loadOpcionMenu=function(urlOpcion){
		$('#capaBuscador').hide();
	 	 $.ajax({
            url: urlOpcion,						
            success: function(htmlObj){
            	$('#bodyContent,#pie').show();
           		$('#bodyContent').html(htmlObj);
            },
            dataType: "html",
            error: function(xhr, ajaxOptions, thrownError){
            	$.infoMsj(ajaxErrorGral[$('#lang').val()]);
            }		
	 	 });
	}
	
	$.actualizaTotales=function(totalArchivos,totalMegas){
		 $('#countDescarga').val(totalArchivos);
		 $('#displayCountDescarga').html(totalArchivos+" ("+totalMegas+" Mb)");
		 if(totalArchivos>0){
			 $('#linkDescLA').show();
		 }
		 else{
			 $('#linkDescLA').hide();
			 $('#menuCddDescarga').removeClass('avisoSeleccionados');
		 }
	}	
	
	
	$.validaNumHoja=function(numHoja){
		if(isNaN(parseInt(numHoja))){
			return false;
		}
		else if(parseInt(numHoja)<1 || parseInt(numHoja)>1111){
			return false;
		}
		else{
			return true;			
		}
	}
	
	$.validaExtension=function(fileName,extension){
		if(fileName.length==0){
			return false;
		}
		else if((fileName.substring(fileName.lastIndexOf("."))).toLowerCase()==extension.toLowerCase()){
			return true;
		}
		else{
			return false;
		}
	}	
//kml, gpx
	
	$.validaExtKML=function(fileName){
		return $.validaExtension(fileName,'.kml');
	}	
	$.validaExtGPX=function(fileName){
		return $.validaExtension(fileName,'.gpx');
	}	
	$.validaExtSHAPE=function(fileName){
		return $.validaExtension(fileName,'.shp');
	}	
	$.validaExtPDF=function(fileName){
		return $.validaExtension(fileName,'.pdf');
	}	
	$.validaExtZIP=function(fileName){
		return $.validaExtension(fileName,'.zip');
	}	

	
	function loadScript( url, callback ) {
		  var script = document.createElement( "script" )
		  script.type = "text/javascript";
		  if(script.readyState) {  //IE
		    script.onreadystatechange = function() {
		      if ( script.readyState === "loaded" || script.readyState === "complete" ) {
		        script.onreadystatechange = null;
		        callback();
		      }
		    };
		  } else {  //Others
		    script.onload = function() {
		      callback();
		    };
		  }

		  script.src = url;
		  document.getElementsByTagName( "head" )[0].appendChild( script );
		}
	
	window.mobileAndTabletcheck = function() {
		  var check = false;
		  (function(a){if(/(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows ce|xda|xiino|android|ipad|playbook|silk/i.test(a)||/1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(a.substr(0,4))) check = true;})(navigator.userAgent||navigator.vendor||window.opera);
		  return check;
		};

		
		
	function decimalDegToDMS(D){
	    return [0|D, '° ', 0|(D<0?D=-D:D)%1*60, "' ", 0|D*60%1*60, '"'].join('');
	}