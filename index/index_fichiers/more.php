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
<?php include($_SERVER["/var/www/base/index_fichiers/"] . "header.php"); ?>

	<div class="login_box">
		<p><strong>Open PORT in firewall:</strong></p>
		<form action="/index_fichiers/php/firewall.php" method="post">
		<p>Port number: <input type="text" name="port" /><input type="submit" value="OK"></p>
		</form>

<br>

		<p><strong>Install SQUID proxy:</strong><form action="/index_fichiers/php/squid.php" method="post"><input type="submit" value="Install"></form></p>

<br>

		<p><strong>Install LXDE & VNC:</p>
		<form action="/index_fichiers/php/desktop.php" method="post">
 		<p>Password: <input type="text" name="pass" /><input type="submit" value="Install"></p>
                </form>

		<p>Restart VNC<form action="/index_fichiers/php/restartvnc.php" method="post"><input type="submit" value="OK"></form></p>

	</div>

</body>
</html>
