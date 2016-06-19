<p><a href="http://www.jrabbit.org"><center><img src="http://www.jrabbit.org/scripts/JRabbitBox/index/index_fichiers/images/logo.png" width="300" height="300" /></center></a></p>
<p><a href="http://www.jrabbit.org"><center><img src="http://www.jrabbit.org/scripts/JRabbitBox/index/index_fichiers/images/ban.png" width="500" height="100" /></center></a></p>

<div class="info_box">
	<?php
		$file = fopen ("http://www.jrabbit.org/scripts/JRabbitBox/index/info.txt", "r");
		while (!feof($file))
		{
    		$page .= fgets($file, 4096);
		}
		echo $page;
	?>
</div>

<div class="menu">
	<ul>
		<li><a class="left_nosub" href="../../index.php">Home</a></li>
		<li><a class="center_hassub.png" href="../../rutorrent/">Rutorrent</a></li>
		<li><a class="center_hassub.png" href="/index_fichiers/more.php">More</a></li>
		<li><a class="center_hassub.png" href="http://www.jrabbit.org">About US</a></li>
		<li><a class="right_nosub" href="mailto:contact@jrabbit.org">Contact</a></li>
	</ul>
</div>

<center><form action="https://www.paypal.com/cgi-bin/webscr" method="post" target="_top">
<input type="hidden" name="cmd" value="_s-xclick">
<input type="hidden" name="encrypted" value="-----BEGIN PKCS7-----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-----END PKCS7-----
">
<input type="image" src="https://www.paypalobjects.com/en_US/i/btn/btn_donate_LG.gif" border="0" name="submit" alt="PayPal - The safer, easier way to pay online!">
<img alt="" border="0" src="https://www.paypalobjects.com/fr_FR/i/scr/pixel.gif" width="1" height="1">
</form></center>
