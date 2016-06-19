<!doctype html>

<html lang="en">
<head>
  <meta charset="utf-8">

  <title>JRabbitBox Index</title>
  <meta name="description" content="The HTML5 Herald">
  <meta name="warezcmpt" content="index">

  <link rel="stylesheet" href="/index_fichiers/JRabbit.css">

  <!--[if lt IE 9]>
  <script src="http://html5shiv.googlecode.com/svn/trunk/html5.js"></script>
  <![endif]-->
</head>

<body>
	<?php include($_SERVER["var/www/base/index_fichiers/"] . "index_fichiers/header.php"); ?>

	<div class="login_box">
		<?php
			$file2 = fopen ("config.txt", "r");
			while (!feof($file2))
			{
			$page2 .= fgets($file2, 4096);
			}
			echo $page2;
		?>
	</div>

        <?php include($_SERVER["var/www/base/index_fichiers/"] . "index_fichiers/footer.php"); ?>

</body>
</html>
