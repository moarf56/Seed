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
        <?php include($_SERVER["/var/www/base/index_fichiers/"] . "../header.php"); ?>

<div class="login_box">
                <?php
                $output = shell_exec("sudo -u www-data sudo bash ../bash/restartvnc.sh ");
                echo "<pre>$output</pre>";
                ?>
        </div>

</body>
</html>
