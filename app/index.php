<?php
session_start();

// Load environment values
$appTitle = getenv('APP_TITLE') ?: 'My To-Do List';
$appVersion = getenv('APP_VERSION') ?: 'v0.0.1';
$footerText = getenv('FOOTER_TEXT') ?: 'Default deployment footer';

// Redis status section
$redisMessage = '';
$masterStatus = '❌ Unknown';

try {
    $redis = new Redis();
    $redis->connect('127.0.0.1', 6379);

    $info = $redis->info('replication');
    $role = $info['role'] ?? 'unknown';

    if ($role === 'slave') {
        $masterHost = $info['master_host'] ?? 'N/A';
        $masterPort = $info['master_port'] ?? '6379';

        // Try pinging the master
        $master = new Redis();
        $masterConnected = @$master->connect($masterHost, $masterPort, 1); // 1s timeout

        if ($masterConnected && $master->ping() === '+PONG') {
            $masterStatus = '🟢 UP';
        } else {
            $masterStatus = '🔴 DOWN';
        }

        $redisMessage = "🟢 Connected as Redis <strong>replica</strong><br>
                         📡 Master: <strong>$masterHost:$masterPort</strong><br>
                         🩺 Master status: <strong>$masterStatus</strong>";

        if ($status = $redis->get("status")) {
            $redisMessage .= "<br>📦 Redis status key: $status";
        }

    } elseif ($role === 'master') {
        $redis->set("status", "✅ Redis master is working");
        $redisMessage = "✅ Connected to Redis <strong>master</strong> and wrote test key.";
    } else {
        $redisMessage = "⚠️ Connected to Redis but role is <strong>unknown</strong>.";
    }

} catch (Exception $e) {
    $redisMessage = "❌ Redis connection failed: " . $e->getMessage();
}

// Session task list
if (!isset($_SESSION['tasks'])) {
    $_SESSION['tasks'] = [];
}
?>

<!DOCTYPE html>
<html>
<head>
    <title><?= htmlspecialchars($appTitle) ?></title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
<div class="container">
    <h2><?= htmlspecialchars($appTitle) ?></h2>

    <!-- Redis status -->
    <div style="padding:10px; margin-bottom:15px; background:#f8f8ff; border:1px solid #ccc; text-align:center;">
        <?= $redisMessage ?>
    </div>

    <!-- Task form -->
    <form action="add.php" method="POST">
        <input type="text" name="task" placeholder="Enter a new task" required>
        <button type="submit">Add Task</button>
    </form>

    <!-- Task list -->
    <ul>
        <?php foreach ($_SESSION['tasks'] as $index => $task): ?>
            <li>
                <?= htmlspecialchars($task) ?>
                <a href="delete.php?index=<?= $index ?>" class="delete">Delete</a>
            </li>
        <?php endforeach; ?>
    </ul>

    <!-- Footer -->
    <div style="text-align:center; font-size:12px; margin-top:30px;">
        <hr>
        <p>Version: <?= htmlspecialchars($appVersion) ?></p>
        <p><?= htmlspecialchars($footerText) ?></p>
    </div>
</div>
</body>
</html>
