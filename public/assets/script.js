function getConfidence(t){return t>=0&&19>=t?"very unlikely":t>=20&&39>=t?"unlikely":t>=40&&59>=t?"possible":t>=60&&79>=t?"likely":"certain"}$(document).ready(function(){var t=1400,e=1800,i=40,n=0,s=100;$("#search-network").tooltip({placement:"right",title:"Connections of one individual"}),$("#search-shared-network").tooltip({placement:"right",title:"New Feature Coming Soon"}),$("#search-group").tooltip({placement:"right",title:"Members of one group"}),$("#search-shared-group").tooltip({placement:"right",title:"New Feature Coming Soon"}),$("#contribute-add-person").tooltip({placement:"right",title:"Add a new individual to the database"}),$("#contribute-add-group").tooltip({placement:"right",title:"Add a new group to the database"}),$("#contribute-add-relationship").tooltip({placement:"right",title:"Add and annotate a relationship between two individuals"}),$("#icon-tag").tooltip({placement:"right",title:"Tag group"}),$("#icon-link").tooltip({placement:"right",title:"Add a relationship"}),$("#icon-annotate").tooltip({placement:"right",title:"Annotate relationship"}),$("#icon-info").tooltip({placement:"left",title:"Scroll to zoom, double click on node or edge for more information, single click to reset view"}),$("#icon-color").tooltip({placement:"left",title:"Click to view color legend"}),$("#node-icon-chain").tooltip({placement:"right",title:"Add relationship"}),$("#node-icon-annotate").tooltip({placement:"right",title:"Edit person"}),$("#edge-icon-annotate").tooltip({placement:"right",title:"Edit relationship"}),$("#group-icon-label").tooltip({placement:"right",title:"Add person to group"}),$("#group-icon-annotate").tooltip({placement:"right",title:"Edit group"}),$(".icon-zoomin").tooltip({placement:"left",title:"Zoom In"}),$(".icon-zoomout").tooltip({placement:"left",title:"Zoom Out"}),$(".icon-color").tooltip({placement:"left",title:"Colors"}),$(".icon-info").tooltip({placement:"left",title:"Info"}),$("#search-network-slider-confidence").tooltip({placement:"right",title:"Choose the certainty"}),$("#search-network-slider-date").tooltip({placement:"right",title:"Choose the date range"}),$("#search-shared-network-slider-confidence").tooltip({placement:"right",title:"Choose the certainty"}),$("#search-shared-network-slider-date").tooltip({placement:"right",title:"Choose the date range"}),$("#nav-slider-confidence").tooltip({placement:"right",title:"Choose the Certainty Threshold, then Click Filter"}),$("#nav-slider-date").tooltip({placement:"right",title:"Choose the Date Range, then Click Filter"}),$("#search-network-form").css("display","block"),$("#search-network-show-table").click(function(){$("#search-network-show-table").attr("href","/people/"+$("#search-network-name-id").val())}),$("#icon-color").click(function(){"none"==$("#guide").css("display")?$("#guide").css("display","block"):$("#guide").css("display","none")}),$("#guide").click(function(){$("#guide").css("display","none")}),$(".accordion_content ul li").click(function(t){$(".accordion_content ul li").removeClass("clicked"),$(this).addClass("clicked"),$("section").css("display","none");var e="#"+t.target.id+"-form";$(e).css("display","block")}),$(".toggle").click(function(){$(".toggle").removeClass("active"),$(this).addClass("active")}),$("#search-shared-group").click(function(){$("#search-shared-group-form").css("display","block")}),$("section button").click(function(){"node"==this.name?$("#zoom").css("display","block"):"group"==this.name&&$("#zoom").css("display","none")}),$("aside button.icon").click(function(){$(".accordion_content ul li").removeClass("clicked"),$("section").css("display","none"),$("#add"+this.name).addClass("clicked"),$("#add"+this.name+"form").css("display","block"),$("#accordion h3").removeClass("on"),$("#accordion div").slideUp(),$("#contribute").prev().addClass("on"),$("#contribute").slideDown()}),$("#search-network-slider-confidence").slider({animate:!0,range:"min",value:i,min:n,max:s,step:1,values:[n,s],slide:function(t,e){var i=getConfidence(e.values[0]),n=getConfidence(e.values[1]);$("#search-network-slider-confidence-result").html(i+" to "+n+" relationships @ "+e.values[0]+" - "+e.values[1]+"%"),$("#search-network-slider-confidence-result-hidden").val(e.values[0]+" - "+e.values[1])}}),$("#search-network-slider-date").slider({animate:!0,range:"min",value:3,min:t,max:e,step:1,values:[t,e],slide:function(t,e){$("#search-network-slider-date-result").html("Date Range: "+e.values[0]+" - "+e.values[1]),$("#search-network-slider-date-result-hidden").val(e.values[0]+" - "+e.values[1])}}),$("#search-network-name").keyup(function(t){13==t.keyCode&&$("#search-network-submit").click()}),$("#search-shared-network-slider-confidence").slider({animate:!0,range:"min",value:i,min:n,max:s,step:1,values:[n,s],slide:function(t,e){var i=getConfidence(e.values[0]),n=getConfidence(e.values[1]);$("#search-shared-network-slider-confidence-result").html(i+" to "+n+" relationships @ "+e.values[0]+" - "+e.values[1]+"%"),$("#search-shared-network-slider-confidence-result-hidden").val(e.values[0]+" - "+e.values[1])}}),$("#search-shared-network-slider-date").slider({animate:!0,range:"min",value:3,min:t,max:e,step:1,values:[t,e],slide:function(t,e){$("#search-shared-network-slider-date-result").html("Date Range: "+e.values[0]+" - "+e.values[1]),$("#search-shared-network-slider-date-result-hidden").val(e.values[0]+" - "+e.values[1])}}),$("#search-shared-network-name1").keyup(function(t){13==t.keyCode&&$("#search-shared-network-submit").click()}),$("#search-shared-network-name2").keyup(function(t){13==t.keyCode&&$("#search-shared-network-submit").click()}),$("#nav-slider-confidence").slider({animate:!0,range:"min",value:3,min:n,max:s,step:1,values:[n,s],slide:function(t,e){var i=getConfidence(e.values[0]),n=getConfidence(e.values[1]);$("#nav-slider-confidence-result").html(i+" to "+n+" relationships @ "+e.values[0]+" - "+e.values[1]+"%"),$("#nav-slider-confidence-result-hidden").val(e.values[0]+" - "+e.values[1])}}),$("#nav-slider-date").slider({animate:!0,range:"min",value:3,min:t,max:e,step:1,values:[t,e],slide:function(t,e){$("#nav-slider-date-result").val(e.values[0]+" - "+e.values[1])}}),$("#nav-anchor").click(function(){$("#nav-slider").toggleClass("nav-slider-show")}),$("#slider1").change(function(){var t=$("#slider1").val(),e="Very unlikely";t>19&&40>t?e="Unlikely":t>39&&60>t?e="Possible":t>59&&80>t?e="Likely":t>79&&(e="Certain"),$("#formCertainty").html(e+" relationships @ "+t+"%")})});