<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <title>sudden_death</title>
</head>

<form>
    <input type="text" name="text" value="" />
    <input type="submit" value="generate" />
</form>

<?php

// good job. this challenge is pwnable. flag in /home/death/flag

if (isset($_GET['text'])) {
    $text = $_GET['text'];
    echo '<pre>';
    system("./death-10a035bee652b3f10a4187a79e758378 $(echo -n '$text' | cut -c 1-10)");
    echo '</pre>';
}

?>

</html>
