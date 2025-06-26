<?php
session_start();

if (isset($_GET['index'])) {
    $index = (int) $_GET['index'];
    if (isset($_SESSION['tasks'][$index])) {
        unset($_SESSION['tasks'][$index]);
        $_SESSION['tasks'] = array_values($_SESSION['tasks']); // reindex array
    }
}

header('Location: index.php');
exit();
