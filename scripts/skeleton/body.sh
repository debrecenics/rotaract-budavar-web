BODY="<!---->
<div id=\"wrapper\">
<div class=\"header\">
	 <div class=\"container\">
		 <div class=\"languages\">
			$langSelect
		 </div>
		 <div class=\"logo logo-title\">
			 Budapest<b>Budavár</b>
		 </div>
		 <div class=\"top-menu\">
				<span class=\"menu\"> </span>
				<ul>
					 $menuSelect
				 </ul>
		 </div>
		 <div class=\"clearfix\"></div>
			 <!--script-nav-->
			 <script src=\"${relPath}js/responsiveslides.min.js\"></script>
		 <script>
		 \$(\"span.menu\").click(function(){
		 \$(\".top-menu ul\").slideToggle(\"slow\" , function(){
		 });
		 });
		 </script>
		 <script>
			 \$(function () {
				 \$(\"#slider\").responsiveSlides({
				 auto: true,
				 nav: true,
				 speed: 500,
				 namespace: \"callbacks\",
				 pager: true,
				 });
			 });
 </script>
	 </div>
</div>
$content
</div>
"
