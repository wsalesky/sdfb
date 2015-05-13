function getClusterRels(e){try{{Object.keys(e).length}}catch(t){}}function getClusterRels(e){try{var t=Object.keys(e).length}catch(a){var t=0}return t>=50?6:t>=30?5:t>=20?4:t>=10?3:t>=5?2:t>=1?1:0}function getColorsRels(){return{0:"#bdbdbd",1:"#d73027",2:"#f46d43",3:"#fdae61",4:"#abd9e9",5:"#74add1",6:"#4575b4"}}function notInArray(e,t){for(var a=e.length;a--;){if(e[a][0]==t[0]&&e[a][1]==t[1])return!1;if(e[a][1]==t[0]&&e[a][0]==t[1])return!1}return!0}function createNodeKey(e,t){return{text:e.display_name,size:10,id:t,cluster:getClusterRels(e.rel_sum)}}function twoDegs(e,t,a){function i(e,t){var a=t[e];$.each(a.rel_sum,function(a,i){var o=i[0];n[o]=createNodeKey(t[o],o),notInArray(r,[e,i[0]])&&r.push([e,i[0]]),$.each(t[o].rel_sum,function(e,a){var o=a[0];o in t&&(n[o]=createNodeKey(t[o],o),notInArray(r,[i[0],a[0]])&&r.push([i[0],a[0]]))})}),n[e]={text:a.display_name,size:30,id:e,cluster:getClusterRels(a.rel_sum)}}var n={},r=[],o=[];i(e,a),0!=t&&""!=t&&(i(t,a),n[t]={text:a[t].display_name,size:30,id:t,cluster:getClusterRels(a[t].rel_sum)},n[e]={text:a[e].display_name,size:30,id:e,cluster:getClusterRels(a[e].rel_sum)}),$.each(n,function(e,t){o.push(t)}),r.reverse();var l=window.innerWidth,s=window.innerHeight,d={width:l,height:s,collisionAlpha:25,colors:getColorsRels()},c=new Insights($("#graph")[0],o,r,d).render();c.on("node:click",function(e){a[e.id];$.ajax({type:"GET",url:"/node_info",data:{node_id:e.id},datatype:"html",success:function(){},async:!0}),accordion("node")}),c.on("edge:click",function(e){parseInt(e.source.id),parseInt(e.target.id);$.ajax({type:"GET",url:"/network_info",data:{source_id:e.source.id,target_id:e.target.id},datatype:"html",success:function(){},async:!0}),accordion("edge")}),c.tooltip("<div class='btn' >{{text}}</div>"),$("#zoom button.icon").click(function(){"in"==this.name?(c.zoomIn(),c.center()):"out"==this.name&&(c.zoomOut(),c.center())})}function getConfidence(e){return e>=0&&19>=e?"Very Unlikely":e>=20&&39>=e?"Unlikely":e>=40&&59>=e?"Possible":e>=60&&79>=e?"Likely":"Certain"}function getParam(e){var t=location.search.substr(location.search.indexOf("?")+1),a="";t=t.split("&");for(var i=0;i<t.length;i++)temp=t[i].split("="),[temp[0]]==e&&(a=temp[1]);return a}function filterGraph(e){var t=getParam("id"),a=getParam("id2");(""==a||"0"==a)&&(a=0),""==t&&(t=francisID),twoDegs(t,a,e)}function initGraph(e){var t=default_sconfidence+" to "+default_econfidence,a=default_sdate+" - "+default_edate;if(getParam("id")>0)var i=e[parseInt(getParam("id"))].display_name;else var i=e[francisID].display_name;if(getParam("id2")>0)var n=" and "+e[parseInt(getParam("id2"))].display_name;else var n="";getParam("confidence").length>0&&(t=getParam("confidence").replace(",","% to ")),getParam("date").length>0&&(a=getParam("date").replace(","," to ")),$("#results").html("Two Degrees of "+i+n+" at "+t+"% from "+a+" (100 node display limit)")}function sidebarSearch(){$("#search-network-submit").click(function(){var e="no";Pace.restart();var t=$("#search-network-name-id").val();1==$("#show-table").val()&&(e="yes");var a=$("#search-network-slider-confidence-result-hidden").val().split(" - "),i=$("#search-network-slider-date-result-hidden").val().split(" - ");t&&a&&i&&(window.location.href="/?id="+t+"&confidence="+a+"&date="+i)}),$("#search-shared-network-submit").click(function(){var e="no";if(Pace.restart(),$("#search-shared-network-name1-id").val())var t=$("#search-shared-network-name1-id").val();if($("#search-shared-network-name2-id").val())var a=$("#search-shared-network-name2-id").val();1==$("#show-table").val()&&(e="yes");var i=$("#search-shared-network-slider-confidence-result-hidden").val().split(" - "),n=$("#search-shared-network-slider-date-result-hidden").val().split(" - ");t&&a&&n&&i&&(window.location.href="/?id="+t+"&id2="+a+"&confidence="+i+"&date="+n+"&table="+e)}),$("#search-group-submit").click(function(){Pace.restart();var e=$("#search-group-name-id").val();e&&(window.location.href="/?group="+e)}),$("#search-shared-group-submit").click(function(){Pace.restart();var e=$("#search-shared-group-name1-id").val(),t=$("#search-shared-group-name2-id").val();e&&t&&(window.location.href="/?group="+e+"&group2="+t)}),$("#nav-filter-submit").click(function(){var e=getParam("id"),t=getParam("id2");ID2Str=""!=t?"&id2="+t:"";var a=$("#nav-slider-confidence-result-hidden").val().split(" - "),i=$("#nav-slider-date-result-hidden").val().split(" - ");""!=e&&(window.location.href="/?id="+e+ID2Str+"&confidence="+a+"&date="+i),""==e&&(window.location.href="/?id="+francisID+ID2Str+"&confidence="+a+"&date="+i)}),$("aside button.icon").click(function(){addNodes=[],addEdges=[];var e=$("#node-name").html()+" ("+$("#node-bdate").html()+")";"icon-tag"==this.id?$("#entry_1177061505").val(e):"icon-link"==this.id&&$("#entry_768090773").val(e)})}function init(){var e=window.gon.people,t=(window.gon.group_data,window.gon.group),a=window.gon.group2,i=window.gon.group_members;sidebarSearch(e),void 0!=e&&("nodelimit"==e[0]&&($("#kickback").show(),$("#kickbackyes").attr("href","/people_relationships?id="+e[1]),$("#kickbackno").click(function(){$("#kickback").hide(),$("#search-button").click()})),"nodelimit_network"==e[0]&&($("#kickback").show(),$("#kickbackyes").attr("href","/relationships/"+e[1]),$("#kickbackno").click(function(){$("#kickback").hide(),$("#search-button").click(),$("#search-shared-network").click()}))),0==getParam("group").length?(filterGraph(e),initGraph(e),$("#group-table").hide()):(accordion("group"),$("#filterBar").hide(),$("#group-name").text(t.name),$("#group-description").text(t.description),$("#group-discussion").attr("href","groups/"+t.id),$("#group-icon-annotate").attr("href","/user_group_contribs/new?group_id="+t.id),$("#group-icon-tag").attr("href","/group_assignments/new?group_id="+t.id),$(".group2").hide(),"undefined"!=typeof a&&($("#group-name2").text(a.name),$("#group-description2").text(a.description),$("#group-discussion2").attr("href","groups/"+a.id),$(".group2").show(),$("#group-icon-annotate2").attr("href","/user_group_contribs/new?group_id="+a.id),$("#group-icon-tag2").attr("href","/group_assignments/new?group_id="+a.id)),$.each(i,function(e){$("#group-table").append("<div class='group-row'><div class='col-md'>"+i[e].display_name+"</div><div class='col-md'>"+i[e].ext_birth_year+"</div><div class='col-md'>"+i[e].ext_death_year+"</div><div class='col-md'><a href='/people/"+i[e].id+"'>"+ +i[e].id+"</a></div></div>")}))}var francisID=10000473,default_sconfidence=60,default_econfidence=100,default_sdate=1400,default_edate=1800;$("#zoom button.icon").click(function(){"in"==this.name?graph.zoomIn():graph.zoomOut()}),$(document).ready(function(){init()});