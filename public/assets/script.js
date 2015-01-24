$(document).ready(function(){$("#onenode").tooltip({placement:"right",title:"Connections of one individual"}),$("#twonode").tooltip({placement:"right",title:"Mutual connections between two individuals"}),$("#onegroup").tooltip({placement:"right",title:"Members of one group"}),$("#twogroup").tooltip({placement:"left",title:"Mutual members of two groups"}),$("#addnode").tooltip({placement:"right",title:"Add a new individual to the database"}),$("#addgroup").tooltip({placement:"right",title:"Add a new group to the database"}),$("#addedge").tooltip({placement:"right",title:"Add and annotate a relationship between two individuals"}),$("#icon-tag").tooltip({placement:"right",title:"Tag group"}),$("#icon-link").tooltip({placement:"right",title:"Add a relationship"}),$("#icon-annotate").tooltip({placement:"right",title:"Annotate relationship"}),$("#icon-info").tooltip({placement:"left",title:"Scroll to zoom, double click on node or edge for more information, single click to reset view"}),$("#icon-color").tooltip({placement:"left",title:"Click to view color legend"}),$("#node-icon-chain").tooltip({placement:"right",title:"Add relationship"}),$("#node-icon-annotate").tooltip({placement:"right",title:"Edit person"}),$("#edge-icon-annotate").tooltip({placement:"right",title:"Edit relationship"}),$("#group-icon-label").tooltip({placement:"right",title:"Add person to group"}),$("#group-icon-annotate").tooltip({placement:"right",title:"Edit group"}),$(".icon-zoomin").tooltip({placement:"left",title:"Zoom In"}),$(".icon-zoomout").tooltip({placement:"left",title:"Zoom Out"}),$(".icon-color").tooltip({placement:"left",title:"Colors"}),$(".icon-info").tooltip({placement:"left",title:"Info"}),$(".slider").tooltip({placement:"right",title:"Choose the certainty of relationship"}),$("#onenodeform").css("display","block"),$("#icon-color").click(function(){"none"==$("#guide").css("display")?$("#guide").css("display","block"):$("#guide").css("display","none")}),$("#guide").click(function(){$("#guide").css("display","none")}),$(".accordion_content ul li").click(function(t){$(".accordion_content ul li").removeClass("clicked"),$(this).addClass("clicked"),$("section").css("display","none");var e="#"+t.target.id+"form";$(e).css("display","block")}),$(".toggle").click(function(){$(".toggle").removeClass("active"),$(this).addClass("active")}),$("#findtwogroup").click(function(){$("#twogroupsmenu").css("display","block")}),$("section button").click(function(){"node"==this.name?$("#zoom").css("display","block"):"group"==this.name&&$("#zoom").css("display","none")}),$("aside button.icon").click(function(){$(".accordion_content ul li").removeClass("clicked"),$("section").css("display","none"),$("#add"+this.name).addClass("clicked"),$("#add"+this.name+"form").css("display","block"),$("#accordion h3").removeClass("on"),$("#accordion div").slideUp(),$("#contribute").prev().addClass("on"),$("#contribute").slideDown()}),$("#node-slider").slider({animate:!0,range:"min",value:40,min:0,max:100,step:1,slide:function(t,e){var n="Very unlikely";e.value>19&&e.value<40?n="Unlikely":e.value>39&&e.value<60?n="Possible":e.value>59&&e.value<80?n="Likely":e.value>79&&(n="Certain"),$("#slider-result1").html(n+" relationships @ "+e.value+"%"),$("#slider-result-hidden1").val(e.value)}}),$("#edge-slider").slider({animate:!0,range:"min",value:40,min:0,max:100,step:1,slide:function(t,e){var n="Very unlikely";e.value>19&&e.value<40?n="Unlikely":e.value>39&&e.value<60?n="Possible":e.value>59&&e.value<80?n="Likely":e.value>79&&(n="Certain"),$("#slideredge-result1").html(n+" relationships @ "+e.value+"%"),$("#slideredge-result-hidden1").val(e.value)}}),$("#nav-slider").slider({animate:!0,range:"min",value:40,min:0,max:100,step:1,slide:function(t,e){var n="Very unlikely";e.value>19&&e.value<40?n="Unlikely":e.value>39&&e.value<60?n="Possible":e.value>59&&e.value<80?n="Likely":e.value>79&&(n="Certain"),$("#slidenav-result1").html(n+" relationships @ "+e.value+"%"),$("#slidenav-result-hidden1").val(e.value)}}),$(".slider-date").slider({animate:!0,range:"min",value:3,min:1400,max:1800,step:1,values:[1400,1800],slide:function(t,e){$("#search-date-range1").val(e.values[0]+" - "+e.values[1])}}),$("#search-date-range1").val($(".slider-date").slider("values",0)+" - "+$(".slider-date").slider("values",1)),$(".slider-date2").slider({animate:!0,range:"min",value:3,min:1400,max:1800,step:1,values:[1400,1800],slide:function(t,e){$("#searchedge-date-range2").val(e.values[0]+" - "+e.values[1])}}),$("#searchedge-date-range2").val($(".slider-date2").slider("values",0)+" - "+$(".slider-date2").slider("values",1)),$("#navslider2").slider({animate:!0,range:"min",value:3,min:1400,max:1800,step:1,values:[1400,1800],slide:function(t,e){$("#nav-date-range2").val(e.values[0]+" - "+e.values[1])}}),$("#nav-date-range2").val($("#navslider2").slider("values",0)+" - "+$("#navslider2").slider("values",1)),$("#slider1").change(function(){var t=$("#slider1").val(),e="Very unlikely";t>19&&40>t?e="Unlikely":t>39&&60>t?e="Possible":t>59&&80>t?e="Likely":t>79&&(e="Certain"),$("#formCertainty").html(e+" relationships @ "+t+"%")}),$("#certainty-anchor").click(function(){$("#nav-certainty-slider").toggle("slow",function(){})}),$("#date-anchor").click(function(){$("#nav-date").toggle("slow",function(){})})});