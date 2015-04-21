function getConfidence(t){return t>=0&&19>=t?"Very Unlikely":t>=20&&39>=t?"Unlikely":t>=40&&59>=t?"Possible":t>=60&&79>=t?"Likely":"Certain"}$(document).ready(function(){var t=1400,e=1800,i=60,n=0,s=100;$("#colorlegend").dialog({autoOpen:!1,height:"auto",show:"slideDown",position:{my:"right top",at:"right-10% top+10%",of:window}}),$("#search-network").tooltip({placement:"right",title:"First- and second-degree network connections of one person"}),$("#search-shared-network").tooltip({placement:"right",title:"First- and second-degree network connections shared by two people"}),$("#search-group").tooltip({placement:"right",title:"Members belonging to a group"}),$("#search-shared-group").tooltip({placement:"right",title:"Members belonging to both groups"}),$("#contribute-add-person").tooltip({placement:"right",title:"Add a new person to the database"}),$("#contribute-add-group").tooltip({placement:"right",title:"Add a new group to the database"}),$("#contribute-add-relationship").tooltip({placement:"right",title:"Add a new, untyped relationship between two people in the database"}),$("#icon-tag").tooltip({placement:"right",title:"Tag group"}),$("#icon-link").tooltip({placement:"right",title:"Add a new, untyped relationship for this person"}),$("#icon-annotate").tooltip({placement:"right",title:"Add a note to this relationship"}),$("#icon-info").tooltip({placement:"left",title:"Scroll to zoom, double click on node or edge for more information, single click to reset view"}),$("#icon-color").click(function(){$("#colorlegend").dialog("open")}),$("#node-icon-chain").tooltip({placement:"right",title:"Add a new, untyped relationship for this person"}),$("#node-icon-annotate").tooltip({placement:"right",title:"Add a note to this person"}),$("#edge-icon-annotate").tooltip({placement:"right",title:"Add a relationship type and note to this relationship"}),$("#group-icon-label").tooltip({placement:"right",title:"Add person to group"}),$("#group-icon-annotate").tooltip({placement:"right",title:"Add a note to this group"}),$(".icon-zoomin").tooltip({placement:"left",title:"Zoom In"}),$(".icon-zoomout").tooltip({placement:"left",title:"Zoom Out"}),$(".icon-info").tooltip({placement:"left",title:"Info"}),$("#search-network-slider-confidence").tooltip({placement:"right",title:"Choose the Confidence Level"}),$("#search-network-slider-date").tooltip({placement:"right",title:"Choose the Date Range"}),$("#search-shared-network-slider-confidence").tooltip({placement:"right",title:"Choose the Confidence Level"}),$("#search-shared-network-slider-date").tooltip({placement:"right",title:"Choose the Date Range"}),$("#nav-slider-confidence").tooltip({placement:"right",title:"Choose the Confidence Level, then Click Filter"}),$("#nav-slider-date").tooltip({placement:"right",title:"Choose the Date Range, then Click Filter"}),$("#search-network-form").css("display","block"),$("#search-network-show-table").click(function(){$("#search-network-show-table").attr("href","/people/"+$("#search-network-name-id").val())}),$(".accordion_content ul li").click(function(t){$(".accordion_content ul li").removeClass("clicked"),$(this).addClass("clicked"),$("section").css("display","none");var e="#"+t.target.id+"-form";$(e).css("display","block")}),$(".toggle").click(function(){$(".toggle").removeClass("active"),$(this).addClass("active")}),$("#search-shared-group").click(function(){$("#search-shared-group-form").css("display","block")}),$("section button").click(function(){"node"==this.name?$("#zoom").css("display","block"):"group"==this.name&&$("#zoom").css("display","none")}),$("aside button.icon").click(function(){$(".accordion_content ul li").removeClass("clicked"),$("section").css("display","none"),$("#add"+this.name).addClass("clicked"),$("#add"+this.name+"form").css("display","block"),$("#accordion h3").removeClass("on"),$("#accordion div").slideUp(),$("#contribute").prev().addClass("on"),$("#contribute").slideDown()}),$("#search-network-slider-confidence").slider({animate:!0,range:"min",value:i,min:n,max:s,step:1,values:[n,s],slide:function(t,e){var i=getConfidence(e.values[0]),n=getConfidence(e.values[1]);$("#search-network-slider-confidence-result").html(i+" to "+n+" @ "+e.values[0]+" - "+e.values[1]+"%"),$("#search-network-slider-confidence-result-hidden").val(e.values[0]+" - "+e.values[1])}}),$("#search-network-slider-date").slider({animate:!0,range:"min",value:3,min:t,max:e,step:1,values:[t,e],slide:function(t,e){$("#search-network-slider-date-result").html("Selected Years: "+e.values[0]+" - "+e.values[1]),$("#search-network-slider-date-result-hidden").val(e.values[0]+" - "+e.values[1])}}),$("#search-network-name").keyup(function(t){13==t.keyCode&&$("#search-network-submit").click()}),$("#search-shared-network-slider-confidence").slider({animate:!0,range:"min",value:i,min:n,max:s,step:1,values:[n,s],slide:function(t,e){var i=getConfidence(e.values[0]),n=getConfidence(e.values[1]);$("#search-shared-network-slider-confidence-result").html(i+" to "+n+" @ "+e.values[0]+" - "+e.values[1]+"%"),$("#search-shared-network-slider-confidence-result-hidden").val(e.values[0]+" - "+e.values[1])}}),$("#search-shared-network-slider-date").slider({animate:!0,range:"min",value:3,min:t,max:e,step:1,values:[t,e],slide:function(t,e){$("#search-shared-network-slider-date-result").html("Selected Years: "+e.values[0]+" - "+e.values[1]),$("#search-shared-network-slider-date-result-hidden").val(e.values[0]+" - "+e.values[1])}}),$("#search-shared-network-name1").keyup(function(t){13==t.keyCode&&$("#search-shared-network-submit").click()}),$("#search-shared-network-name2").keyup(function(t){13==t.keyCode&&$("#search-shared-network-submit").click()}),$("#nav-slider-confidence").slider({animate:!0,range:"min",value:3,min:n,max:s,step:1,values:[n,s],slide:function(t,e){var i=getConfidence(e.values[0]),n=getConfidence(e.values[1]);$("#nav-slider-confidence-result").html(i+" to "+n+" @ "+e.values[0]+" - "+e.values[1]+"%"),$("#nav-slider-confidence-result-hidden").val(e.values[0]+" - "+e.values[1])}}),$("#nav-slider-date").slider({animate:!0,range:"min",value:3,min:t,max:e,step:1,values:[t,e],slide:function(t,e){$("#nav-slider-date-result").val(e.values[0]+" - "+e.values[1])}}),$("#nav-anchor").click(function(){$("#nav-slider").toggleClass("nav-slider-show")}),$("#slider1").change(function(){var t=$("#slider1").val(),e="Very Unlikely";t>19&&40>t?e="Unlikely":t>39&&60>t?e="Possible":t>59&&80>t?e="Likely":t>79&&(e="Certain"),$("#formCertainty").html(e+" @ "+t+"%")})});